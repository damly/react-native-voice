package com.damly.voice.recognizer;

import android.util.Log;

import com.damly.voice.recognizer.microsoft.SpeechClient;
import com.damly.voice.recognizer.recorder.PcmRecorder;
import com.damly.voice.recognizer.recorder.PcmRecorderListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;


import org.json.JSONObject;


/**
 * Created by damly on 2018/1/17.
 */

public class MicrosoftRecognizerModule extends ReactContextBaseJavaModule {

    private static PcmRecorder mPcmRecorder = null;
    private static VoiceRecognizerJsEvent mVoiceRecognizerJsEvent = null;
    private static boolean isRecording = false;
    private static boolean isCancel = false;
    private static String mFileName = "";
    private static String mLangCode = "";
    private static SpeechClient mSpeechClient = null;

    public MicrosoftRecognizerModule(ReactApplicationContext reactContext) {
        super(reactContext);

        mFileName = reactContext.getFilesDir().getAbsolutePath() + "/microsoft.pcm";

        mVoiceRecognizerJsEvent = new VoiceRecognizerJsEvent(reactContext);

        mPcmRecorder = new PcmRecorder(reactContext, new PcmRecorderListener() {
            @Override
            public void onStart() {
                isRecording = true;
            }

            @Override
            public void onFinish() {

                if (isCancel) {
                    mVoiceRecognizerJsEvent.onCancel();
                    return;
                }

                if (mSpeechClient != null) {
                    try {
                        mSpeechClient.setLanguage(mLangCode);
                        JSONObject res = mSpeechClient.process(mFileName);
                        if (!res.getString("RecognitionStatus").equals("Success")) {
                            mVoiceRecognizerJsEvent.onError(-1, res.getString("err_msg"));
                            return;
                        } else {
                            String result = res.getString("DisplayText");
                            mVoiceRecognizerJsEvent.onResult(result, true, "Microsoft");
                        }

                    } catch (Exception e) {
                        e.printStackTrace();
                        mVoiceRecognizerJsEvent.onError(-1, e.getMessage());
                    }
                }
                isRecording = false;
            }

            @Override
            public void onVolumeChanged(int Volume) {
                mVoiceRecognizerJsEvent.onVolumeChanged(Volume);
            }

            @Override
            public void onError(String message) {
                isRecording = false;
                mVoiceRecognizerJsEvent.onError(-1, message);
            }
        });
    }

    @Override
    public String getName() {
        return "MicrosoftRecognizerModule";
    }

    @ReactMethod
    public void init(String subscriptionKey) {
        mSpeechClient = new SpeechClient(subscriptionKey);
    }

    @ReactMethod
    public void start(String langCode) {
        isCancel = false;
        if (mSpeechClient == null) {
            mVoiceRecognizerJsEvent.onError(-1, "Please call init before start.");
            return;
        }

        mLangCode = langCode;
        mPcmRecorder.startRecording(mFileName);
    }

    @ReactMethod
    public void stop() {
        if (isRecording) {
            mPcmRecorder.stopRecording();
        }
    }

    @ReactMethod
    public void cancel() {
        isCancel = true;
        if (isRecording) {
            mPcmRecorder.stopRecording();
        }
    }

    @ReactMethod
    public void isListening(Promise promise) {
        promise.resolve(isRecording);
    }
}
