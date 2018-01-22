package com.damly.voice.recognizer;

import android.content.Context;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import javax.annotation.Nullable;

/**
 * Created by damly on 2018/1/17.
 */

public class VoiceRecognizerJsEvent {

    private ReactContext mContext = null;

    public VoiceRecognizerJsEvent(ReactContext context) {
        mContext = context;
    }

    public void onVolumeChanged(int volume) {
        WritableMap params = Arguments.createMap();
        params.putInt("volume", volume);
        onJSEvent(mContext, "onVoiceRecognizerVolumeChanged", params);
    }

    public void onCancel() {
        onJSEvent(mContext, "onVoiceRecognizerCancel", null);
    }

    public void onResult(String result, boolean isLast, String provider) {
        WritableMap params = Arguments.createMap();
        params.putString("result", result);
        params.putBoolean("isLast", isLast);
        params.putString("provider", provider);
        onJSEvent(mContext, "onVoiceRecognizerResult", params);
    }

    public void onError(int errorCode, String description){
        WritableMap params = Arguments.createMap();

        params.putInt("errorCode", errorCode);
        params.putString("message", description);

        onJSEvent(mContext, "onVoiceRecognizerError", params);
    }

    private void onJSEvent(ReactContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }
}