package com.damly.voice;

import com.damly.voice.recognizer.BaiduRecognizerModule;
import com.damly.voice.recognizer.IflytekRecognizerModule;
import com.damly.voice.recognizer.MicrosoftRecognizerModule;
import com.damly.voice.synthesizer.BaiduSynthesizerModule;
import com.damly.voice.synthesizer.IflytekSynthesizerModule;
import com.damly.voice.synthesizer.MicrosoftSynthesizerModule;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by damly on 2018/1/10.
 */

public class VoiceManagerPackage implements ReactPackage {

    /**
     * @param reactContext react application context that can be used to create modules
     * @return list of native modules to register with the newly created catalyst instance
     */
    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();

        modules.add(new IflytekRecognizerModule(reactContext));
        modules.add(new IflytekSynthesizerModule(reactContext));

        modules.add(new BaiduRecognizerModule(reactContext));
        modules.add(new BaiduSynthesizerModule(reactContext));

        modules.add(new MicrosoftRecognizerModule(reactContext));
        modules.add(new MicrosoftSynthesizerModule(reactContext));

        return modules;
    }

    /**
     * @param reactContext
     * @return a list of view managers that should be registered with {UIManagerModule}
     */
    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }
}
