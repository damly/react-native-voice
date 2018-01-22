package com.damly.voice.recognizer.recorder;

/**
 * Created by damly on 2018/1/12.
 */

public abstract interface PcmRecorderListener {
    public void onStart();
    public void onFinish();
    public void onVolumeChanged(int Volume);
    public void onError(String message);
}
