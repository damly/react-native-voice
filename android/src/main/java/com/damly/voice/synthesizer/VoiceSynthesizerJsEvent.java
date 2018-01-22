package com.damly.voice.synthesizer;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import javax.annotation.Nullable;

/**
 * Created by damly on 2018/1/17.
 */

public class VoiceSynthesizerJsEvent {
    private ReactContext mContext = null;

    public VoiceSynthesizerJsEvent(ReactContext context) {
        mContext = context;
    }

    public void onStart(String provider) {
        WritableMap params = Arguments.createMap();
        params.putString("provider", provider);
        onJSEvent(mContext, "onVoiceSynthesizerStart", params);
    }

    public void onError(int errorCode, String description){
        WritableMap params = Arguments.createMap();

        params.putInt("errorCode", errorCode);
        params.putString("message", description);

        onJSEvent(mContext, "onVoiceSynthesizerError", params);
    }

    public void onCompleted() {
        onJSEvent(mContext, "onVoiceSynthesizerCompleted", null);
    }

    private void onJSEvent(ReactContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }
}
