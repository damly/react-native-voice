package com.damly.voice.synthesizer;

import android.content.Context;
import android.media.AudioManager;
import android.os.Bundle;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechSynthesizer;
import com.iflytek.cloud.SpeechUtility;
import com.iflytek.cloud.SynthesizerListener;

/**
 * Created by damly on 2018/1/17.
 */

public class IflytekSynthesizerModule extends ReactContextBaseJavaModule {
    private static SpeechSynthesizer mTts;
    private static SynthesizerListener mTtsListener;
    private static AudioManager mAudioManager;
    private static Context mContext;
    private static VoiceSynthesizerJsEvent mVoiceSynthesizerJsEvent;

    public IflytekSynthesizerModule(ReactApplicationContext reactContext) {
        super(reactContext);

        mContext = reactContext;
        mAudioManager = (AudioManager) reactContext.getSystemService(reactContext.AUDIO_SERVICE);
        mVoiceSynthesizerJsEvent = new VoiceSynthesizerJsEvent(reactContext);
    }

    @Override
    public String getName() {
        return "IflytekSynthesizerModule";
    }

    @ReactMethod
    public void init(String appId) {
        SpeechUtility.createUtility(mContext, SpeechConstant.APPID + "=" + appId);
        mTts = SpeechSynthesizer.createSynthesizer(mContext, null);
        mTtsListener = new SynthesizerListener() {

            @Override
            public void onSpeakBegin() {
                mVoiceSynthesizerJsEvent.onStart("iflytek");
            }

            @Override
            public void onBufferProgress(int i, int i1, int i2, String s) {
            }

            @Override
            public void onSpeakPaused() {
            }

            @Override
            public void onSpeakResumed() {
            }

            @Override
            public void onSpeakProgress(int i, int i1, int i2) {
            }

            @Override
            public void onCompleted(SpeechError speechError) {
                mVoiceSynthesizerJsEvent.onCompleted();
            }

            @Override
            public void onEvent(int i, int i1, int i2, Bundle bundle) {
            }
        };
    }

    @ReactMethod
    public void start(String content, String langCode, int pronounce, String speaker) {
        if (mTts.isSpeaking()) {
            mTts.stopSpeaking();
        }

        this.setTtsParam(langCode, pronounce, speaker);

        mTts.startSpeaking(content, mTtsListener);
    }

    @ReactMethod
    public void stop() {
        if (mTts.isSpeaking()) {
            mTts.stopSpeaking();
        }
    }

    @ReactMethod
    public void isSpeaking(Promise promise) {
        promise.resolve(mTts.isSpeaking());
    }

    private void setTtsParam(String langCode, int pronounce, String speaker) {

        // 清空参数
        mTts.setParameter(SpeechConstant.PARAMS, null);

        mTts.setParameter(SpeechConstant.ENGINE_TYPE, SpeechConstant.TYPE_CLOUD);
        // 设置在线合成发音人
        mTts.setParameter(SpeechConstant.VOICE_NAME, speaker);
        //设置合成语速
        mTts.setParameter(SpeechConstant.SPEED, "50");
        //设置合成音调
        mTts.setParameter(SpeechConstant.PITCH, "50");
        //设置合成音量
        mTts.setParameter(SpeechConstant.VOLUME, "50");

        // 设置播放合成音频打断音乐播放，默认为true
        mTts.setParameter(SpeechConstant.KEY_REQUEST_FOCUS, "true");

        //设置播放器音频流类型
        if (mAudioManager.isBluetoothScoOn())
            mTts.setParameter(SpeechConstant.STREAM_TYPE, "" + AudioManager.STREAM_VOICE_CALL);
        else
            mTts.setParameter(SpeechConstant.STREAM_TYPE, "" + AudioManager.STREAM_MUSIC);
    }
}
