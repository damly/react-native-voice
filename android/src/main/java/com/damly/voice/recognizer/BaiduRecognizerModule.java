package com.damly.voice.recognizer;


import android.util.Log;

import com.baidu.aip.speech.AipSpeech;
import com.damly.voice.recognizer.recorder.PcmRecorder;
import com.damly.voice.recognizer.recorder.PcmRecorderListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

/**
 * Created by damly on 2018/1/17.
 */

public class BaiduRecognizerModule extends ReactContextBaseJavaModule {
    private static PcmRecorder mPcmRecorder = null;
    private static VoiceRecognizerJsEvent mVoiceRecognizerJsEvent = null;
    private static boolean isRecording = false;
    private static boolean isCancel = false;
    private static String mFileName;
    private static String mLangCode = "en";
    private static AipSpeech mAipSpeech = null;

    public BaiduRecognizerModule(ReactApplicationContext reactContext) {
        super(reactContext);

        mFileName = reactContext.getFilesDir().getAbsolutePath() + "/baidu.pcm";

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

                try {
                    HashMap<String, Object> options = new HashMap<>();
                    options.put("lan", mLangCode);
                    JSONObject res = mAipSpeech.asr(mFileName, "pcm", 16000, options);
                    Log.e("Baidu",res.toString(2));
                    int errCode = res.getInt("err_no");
                    if (errCode != 0) {
                        mVoiceRecognizerJsEvent.onError(errCode, res.getString("err_msg"));
                        return;
                    } else {
                        JSONArray result = res.getJSONArray("result");
                        mVoiceRecognizerJsEvent.onResult(result.getString(0), true, "Baidu");
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    mVoiceRecognizerJsEvent.onError(-1, e.getMessage());
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
        return "BaiduRecognizerModule";
    }

    @ReactMethod
    public void init(String appId, String appKey, String secretKey) {
        mAipSpeech = new AipSpeech(appId, appKey, secretKey);
        mAipSpeech.setConnectionTimeoutInMillis(1000);
        mAipSpeech.setSocketTimeoutInMillis(6000);
    }

    @ReactMethod
    public void start(String langCode) {
        isCancel = false;
        if (mAipSpeech == null) {
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
