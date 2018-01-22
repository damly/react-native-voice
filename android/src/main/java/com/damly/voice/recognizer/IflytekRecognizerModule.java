package com.damly.voice.recognizer;

import android.os.Bundle;
import android.util.Log;

import com.damly.voice.recognizer.recorder.PcmRecorder;
import com.damly.voice.recognizer.recorder.PcmRecorderListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.SpeechUtility;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;

/**
 * Created by damly on 2018/1/17.
 */

public class IflytekRecognizerModule extends ReactContextBaseJavaModule {
    private static PcmRecorder mPcmRecorder = null;
    private static VoiceRecognizerJsEvent mVoiceRecognizerJsEvent = null;
    private static SpeechRecognizer mIat;
    private static RecognizerListener mIatListener;
    private static boolean isRecording = false;
    private static boolean isCancel = false;
    private static String mFileName;
    private static String mLangCode = "en";
    private static String result = "";
    private ReactApplicationContext mReactContext;

    public IflytekRecognizerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mReactContext = reactContext;

        mFileName = reactContext.getFilesDir().getAbsolutePath() + "/iflytek.pcm";

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

                isRecording = false;
                startListen();
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
        return "IflytekRecognizerModule";
    }

    @ReactMethod
    public void init(String appId) {
        SpeechUtility.createUtility(mReactContext, SpeechConstant.APPID + "=" + appId);

        mIat = SpeechRecognizer.createRecognizer(mReactContext, null);
        mIatListener = new RecognizerListener() {
            @Override
            public void onVolumeChanged(int volume, byte[] bytes) {
            }

            @Override
            public void onBeginOfSpeech() {

            }

            @Override
            public void onEndOfSpeech() {

            }

            @Override
            public void onResult(RecognizerResult results, boolean isLast) {
                onIatResult(results, isLast);
            }

            @Override
            public void onError(SpeechError error) {
                mVoiceRecognizerJsEvent.onError(error.getErrorCode(), error.getErrorDescription());
            }

            @Override
            public void onEvent(int i, int i1, int i2, Bundle bundle) {

            }
        };
    }

    private void startListen() {
        try {
            InputStream in = new FileInputStream(mFileName);
            setIatParam(mLangCode);
            mIat.startListening(mIatListener);
            byte[] buffer = new byte[1024 * 4];
            int n = 0;
            while ((n = in.read(buffer)) != -1) {
                mIat.writeAudio(buffer, 0, n);
            }
            mIat.stopListening();
            in.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static String parseIatResult(String json) {
        StringBuilder ret = new StringBuilder();
        try {
            JSONTokener tokener = new JSONTokener(json);
            JSONObject joResult = new JSONObject(tokener);
            JSONArray words = joResult.getJSONArray("ws");
            for (int i = 0; i < words.length(); i++) {
                // 转写结果词，默认使用第一个结果
                JSONArray items = words.getJSONObject(i).getJSONArray("cw");
                JSONObject obj = items.getJSONObject(0);
                ret.append(obj.getString("w"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ret.toString();
    }

    private void onIatResult(RecognizerResult results, boolean isLast) {
        String text = parseIatResult(results.getResultString());
        result += text;

        if (isLast) {
            mVoiceRecognizerJsEvent.onResult(result, true, "iflytek");
            result = "";
        }
    }

    private void setIatParam(String langCode) {

        String lang = langCode;
        String accent = "mandarin";

        if(langCode.toLowerCase().equals("zh_hk")) {
            accent = "cantonese";
        }

        // 清空参数
        mIat.setParameter(SpeechConstant.PARAMS, null);

        mIat.setParameter(SpeechConstant.AUDIO_SOURCE, "-1");

        // 设置听写引擎
        mIat.setParameter(SpeechConstant.ENGINE_TYPE, SpeechConstant.TYPE_CLOUD);

        // 设置返回结果格式
        mIat.setParameter(SpeechConstant.RESULT_TYPE, "json");

        // 设置语言
        mIat.setParameter(SpeechConstant.LANGUAGE, lang);
        // 设置语言区域
        mIat.setParameter(SpeechConstant.ACCENT, accent);

        // 设置语音前端点:静音超时时间，即用户多长时间不说话则当做超时处理
        mIat.setParameter(SpeechConstant.VAD_BOS, "10000");

        // 设置语音后端点:后端点静音检测时间，即用户停止说话多长时间内即认为不再输入， 自动停止录音
        mIat.setParameter(SpeechConstant.VAD_EOS, "1500");

        // 设置标点符号,设置为"0"返回结果无标点,设置为"1"返回结果有标点
        mIat.setParameter(SpeechConstant.ASR_PTT, "1");
    }

    @ReactMethod
    public void start(String langCode) {
        isCancel = false;

        if (mIat.isListening()) {
            mIat.cancel();
        }

        mLangCode = langCode;


        mPcmRecorder.startRecording(mFileName);
    }

    @ReactMethod
    public void stop() {
        if (isRecording) {
            mPcmRecorder.stopRecording();
        }

        if (mIat.isListening()) {
            mIat.stopListening();
        }
    }

    @ReactMethod
    public void cancel() {
        isCancel = true;
        if (isRecording) {
            mPcmRecorder.stopRecording();
        }

        if (mIat.isListening()) {
            mIat.cancel();
        }
    }

    @ReactMethod
    public void isListening(Promise promise) {
        promise.resolve(isRecording);
    }
}
