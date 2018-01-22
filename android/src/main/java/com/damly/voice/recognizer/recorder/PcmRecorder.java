package com.damly.voice.recognizer.recorder;

import android.content.Context;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioRecord;
import android.media.AudioTrack;
import android.media.MediaRecorder;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by damly on 2018/1/12.
 */

public class PcmRecorder {

    public static final String TAG = "PcmRecorder";
    private volatile boolean isWorking = false;
    private Timer timer;
    private File mRecordFile;
    private int mRecorderSecondsElapsed = 0;
    private AudioRecord mAudioRecord;
    private double mVolume = 0.0f;
    private int mProgressUpdateInterval = 50;
    private DataOutputStream mDataOutputStream;
    private int mBufferSize;
    private Handler mHandler;
    private int mMaxTimeLength = 15000;
    private int mSampleRateInHz = 16000;
    private int mAudioSource = MediaRecorder.AudioSource.MIC;
    private AudioManager mAudioManager;
    private PcmRecorderListener mPcmRecorderListener = null;

    public PcmRecorder(Context context, PcmRecorderListener listener) {
        mPcmRecorderListener = listener;
        mHandler = new Handler(context.getMainLooper());
        mAudioManager = (AudioManager) context.getSystemService(context.AUDIO_SERVICE);
    }

    public void startRecording(String recordingPath) {
        this.startRecording(recordingPath, 15);
    }

    public void startRecording(String recordingPath, int maxTimeSec) {

        String audioSource = "Mic";
        if(mAudioManager.isBluetoothScoOn()) {
            audioSource = "VoiceCall";
        }
        this.mMaxTimeLength = maxTimeSec*1000;
        this.startRecording(recordingPath, 16000, 50, audioSource);
    }

    public void startRecording(String recordingPath, int sampleRateInHz, int updateInterval, String audioSource) {
        if (isWorking) {
            this.stopRecording();
            if(mPcmRecorderListener != null) {
                mPcmRecorderListener.onError("The recorder is not stop.");
            }
            return;
        }

        mProgressUpdateInterval = updateInterval;
        mSampleRateInHz = sampleRateInHz;

        mAudioSource = this.getAudioSourceFromString(audioSource);

        try {
            mRecordFile = new File(recordingPath);
            if (mRecordFile.exists())
                mRecordFile.delete();
            mRecordFile.createNewFile();
            mDataOutputStream = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(mRecordFile)));
            mBufferSize = AudioRecord.getMinBufferSize(mSampleRateInHz, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT);
            mAudioRecord = new AudioRecord(mAudioSource, mSampleRateInHz, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, mBufferSize);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            if(mPcmRecorderListener != null) {
                mPcmRecorderListener.onError(e.getMessage());
            }
            return ;
        } catch (IOException e) {
            if(mPcmRecorderListener != null) {
                mPcmRecorderListener.onError(e.getMessage());
            }
            return;
        }

        Log.e(TAG, "开始录音");
        Log.e(TAG, "录制采样率: " + mSampleRateInHz);

        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                StartRecord();
                isWorking = false;
            }
        });

        thread.start();
        startTimer();

        return;
    }

    public void stopRecording() {
        if (!isWorking) {
            return;
        }
        this.stopTimer();
        isWorking = false;
    }

    private double calculateVolume(byte[] buffer) {
        double sumVolume = 0.0;
        double avgVolume = 0.0;
        double volume = 0.0;

        for (int i = 0; i < buffer.length; i += 2) {
            int v1 = buffer[i] & 0xFF;
            int v2 = buffer[i + 1] & 0xFF;
            int temp = v1 + (v2 << 8);// 小端
            if (temp >= 0x8000) {
                temp = 0xffff - temp;
            }
            sumVolume += Math.abs(temp);
        }

        avgVolume = sumVolume / buffer.length / 2;
        volume = Math.log10(1 + avgVolume) * 10;

        return volume;

    }

    private int getAudioSourceFromString(String audioSource) {
        switch (audioSource) {
            case "Mic":
                return MediaRecorder.AudioSource.MIC;
            case "voiceUpLink":
                return MediaRecorder.AudioSource.VOICE_UPLINK;
            case "VoiceDownLink":
                return MediaRecorder.AudioSource.VOICE_DOWNLINK;
            case "VoiceCall":
                return MediaRecorder.AudioSource.VOICE_CALL;
            case "VoiceRecognition":
                return MediaRecorder.AudioSource.VOICE_RECOGNITION;
            case "VoiceCommunication":
                return MediaRecorder.AudioSource.VOICE_COMMUNICATION;
            case "Default":
            default:
                return MediaRecorder.AudioSource.DEFAULT;
        }
    }

    private void StartRecord() {
        try {

            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mPcmRecorderListener.onStart();
                }
            });

            byte[] buffer = new byte[mBufferSize];
            mAudioRecord.startRecording();
            isWorking = true;
            mVolume = 0.0;

            while (isWorking) {
                int bufferReadResult = mAudioRecord.read(buffer, 0, mBufferSize);
                if (bufferReadResult == AudioRecord.ERROR_INVALID_OPERATION || bufferReadResult == AudioRecord.ERROR_BAD_VALUE) {
                    continue;
                }
                if (bufferReadResult != 0 && bufferReadResult != -1) {
                    mDataOutputStream.write(buffer, 0, bufferReadResult);
                    final double volume = calculateVolume(buffer);
                    mHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            mVolume = volume;
                        }
                    });
                }
            }
            mAudioRecord.stop();
            mAudioRecord = null;
            if (mDataOutputStream != null) {
                mDataOutputStream.flush();
                mDataOutputStream.close();
                mDataOutputStream = null;
            }

            mPcmRecorderListener.onFinish();
        } catch (Throwable t) {
            if(mPcmRecorderListener != null) {
                mPcmRecorderListener.onError(t.getMessage());
            }
        }
    }

    private void startTimer() {
        stopTimer();
        timer = new Timer();
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {

                if((mRecorderSecondsElapsed*mProgressUpdateInterval >= (mMaxTimeLength - mProgressUpdateInterval))) {
                    stopRecording();
                    return;
                }

                if(mPcmRecorderListener != null) {
                    mPcmRecorderListener.onVolumeChanged((int)Math.floor(mVolume));
                }
                mRecorderSecondsElapsed++;
            }
        }, 0, mProgressUpdateInterval);
    }

    private void stopTimer() {

        mRecorderSecondsElapsed = 0;
        if (timer != null) {
            timer.cancel();
            timer.purge();
            timer = null;
        }
    }
}
