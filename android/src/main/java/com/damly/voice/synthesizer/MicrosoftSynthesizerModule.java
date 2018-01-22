package com.damly.voice.synthesizer;

import android.content.Context;
import android.media.AudioManager;

import com.damly.voice.synthesizer.microsoft.Synthesizer;
import com.damly.voice.synthesizer.microsoft.Voice;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

/**
 * Created by damly on 2018/1/17.
 */

public class MicrosoftSynthesizerModule extends ReactContextBaseJavaModule {
    private static Synthesizer mSynthesizer;
    private static Context mContext;
    private static boolean mIsSpeaking = false;
    private static VoiceSynthesizerJsEvent mVoiceSynthesizerJsEvent;

    public MicrosoftSynthesizerModule(ReactApplicationContext reactContext) {
        super(reactContext);

        mContext = reactContext;
        mVoiceSynthesizerJsEvent = new VoiceSynthesizerJsEvent(reactContext);
    }

    @Override
    public String getName() {
        return "MicrosoftSynthesizerModule";
    }

    @ReactMethod
    public void init(String subscriptionKey) {
        mSynthesizer = new Synthesizer(mContext, subscriptionKey);
        mSynthesizer.SetServiceStrategy(Synthesizer.ServiceStrategy.AlwaysService);
    }

    @ReactMethod
    public void start(String content, String langCode, int pronounce, String speaker) {
        mIsSpeaking = true;

        Voice.Gender gender = pronounce == 0 ? Voice.Gender.Female : Voice.Gender.Male;
        Voice voice = new Voice(langCode, gender, speaker);

        mSynthesizer.SetVoice(voice, null);
        mVoiceSynthesizerJsEvent.onStart("Microsoft");

        mSynthesizer.SpeakToAudio(content, new Runnable() {
            @Override
            public void run() {
                mVoiceSynthesizerJsEvent.onCompleted();
            }
        });
    }

    @ReactMethod
    public void stop() {
        mIsSpeaking = false;
        mSynthesizer.stopSound();
    }

    @ReactMethod
    public void isSpeaking(Promise promise) {
        promise.resolve(mIsSpeaking);
    }
}
