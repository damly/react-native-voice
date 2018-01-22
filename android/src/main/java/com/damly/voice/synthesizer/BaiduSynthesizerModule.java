package com.damly.voice.synthesizer;

import android.content.Context;
import android.media.AudioManager;

import com.baidu.tts.client.SpeechError;
import com.baidu.tts.client.SpeechSynthesizer;
import com.baidu.tts.client.SpeechSynthesizerListener;
import com.baidu.tts.client.TtsMode;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

/**
 * Created by damly on 2018/1/17.
 */

public class BaiduSynthesizerModule extends ReactContextBaseJavaModule {
    private static SpeechSynthesizer mSpeechSynthesizer;
    private static AudioManager mAudioManager;
    private static Context mContext;
    private static boolean mIsSpeaking = false;
    private static VoiceSynthesizerJsEvent mVoiceSynthesizerJsEvent;

    public BaiduSynthesizerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;
        mAudioManager = (AudioManager) reactContext.getSystemService(reactContext.AUDIO_SERVICE);
        mVoiceSynthesizerJsEvent = new VoiceSynthesizerJsEvent(reactContext);
    }

    @Override
    public String getName() {
        return "BaiduSynthesizerModule";
    }

    @ReactMethod
    public void init(String appId, String appKey, String secretKey) {
        mSpeechSynthesizer = SpeechSynthesizer.getInstance();
        mSpeechSynthesizer.setContext(mContext);
        mSpeechSynthesizer.auth(TtsMode.ONLINE);
        mSpeechSynthesizer.initTts(TtsMode.ONLINE);
        mSpeechSynthesizer.setAppId(appId);
        mSpeechSynthesizer.setApiKey(appKey, secretKey);
        mSpeechSynthesizer.setSpeechSynthesizerListener(new SpeechSynthesizerListener() {
            @Override
            public void onSynthesizeStart(String s) {
                mIsSpeaking = true;
                mVoiceSynthesizerJsEvent.onStart("Baidu");
            }

            @Override
            public void onSynthesizeDataArrived(String s, byte[] bytes, int i) {

            }

            @Override
            public void onSynthesizeFinish(String s) {
                mIsSpeaking = false;
                mVoiceSynthesizerJsEvent.onCompleted();
            }

            @Override
            public void onSpeechStart(String s) {
                mIsSpeaking = true;
                mVoiceSynthesizerJsEvent.onStart("Baidu");
            }

            @Override
            public void onSpeechProgressChanged(String s, int i) {

            }

            @Override
            public void onSpeechFinish(String s) {
                mIsSpeaking = false;
            }

            @Override
            public void onError(String s, SpeechError speechError) {
                mIsSpeaking = false;
                mVoiceSynthesizerJsEvent.onError(-1, s);
            }
        });

    }

    @ReactMethod
    public void start(String content, String langCode, int pronounce, String speaker) {
        mIsSpeaking = true;

        setParams(pronounce, speaker);
        mSpeechSynthesizer.speak(content);
    }

    @ReactMethod
    public void stop() {
        mIsSpeaking = false;
        mSpeechSynthesizer.stop();
    }

    @ReactMethod
    public void isSpeaking(Promise promise) {
        promise.resolve(mIsSpeaking);
    }

    private void setParams(int pronounce, String speaker) {

        // 以下参数均为选填
        // 设置在线发声音人： 0 普通女声（默认） 1 普通男声 2 特别男声 3 情感男声<度逍遥> 4 情感儿童声<度丫丫>
        mSpeechSynthesizer.setParam(SpeechSynthesizer.PARAM_SPEAKER, speaker);
        // 设置合成的音量，0-9 ，默认 5
        mSpeechSynthesizer.setParam(SpeechSynthesizer.PARAM_VOLUME, "5");
        // 设置合成的语速，0-9 ，默认 5
        mSpeechSynthesizer.setParam(SpeechSynthesizer.PARAM_SPEED, "5");
        // 设置合成的语调，0-9 ，默认 5
        mSpeechSynthesizer.setParam(SpeechSynthesizer.PARAM_PITCH, "5");

        if (mAudioManager.isBluetoothScoOn())
            mSpeechSynthesizer.setAudioStreamType(AudioManager.STREAM_VOICE_CALL);
        else
            mSpeechSynthesizer.setAudioStreamType(AudioManager.STREAM_MUSIC);
    }
}
