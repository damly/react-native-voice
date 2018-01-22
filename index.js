
import {
    NativeModules,
    NativeAppEventEmitter,
    DeviceEventEmitter,
} from 'react-native';

IflytekRecognizer = NativeModules.IflytekRecognizerModule;
IflytekSynthesizer = NativeModules.IflytekSynthesizerModule;

BaiduRecognizer = NativeModules.BaiduRecognizerModule;
BaiduSynthesizer = NativeModules.BaiduSynthesizerModule;

MicrosoftRecognizer = NativeModules.MicrosoftRecognizerModule;
MicrosoftSynthesizer = NativeModules.MicrosoftSynthesizerModule;

const engines =[
    { name:'baidu' }
]

import {recognizers, synthesizers} from './test';

export default class VoiceManager {

    constructor(props) {

        this.recognizers = recognizers;
        this.synthesizers = synthesizers;
        this.currentRecognizer = -1;
        this.currentSynthesizer = -1;

        this.loadAllModules();
   }

    loadAllModules() {

        let i = 0;
        for(i=0; i<this.recognizers.length; i++) {
            if(this.recognizers[i].name.toLowerCase() === 'iflytek') {
                this.recognizers[i].engine = IflytekRecognizer;
                this.recognizers[i].engine.init(this.recognizers[i].appId);
            }
            else if(this.recognizers[i].name.toLowerCase() === 'baidu') {
                this.recognizers[i].engine = BaiduRecognizer;
                this.recognizers[i].engine.init(this.recognizers[i].appId,
                    this.recognizers[i].appKey, this.recognizers[i].secretKey);
            }
            else if(this.recognizers[i].name.toLowerCase() === 'microsoft') {
                this.recognizers[i].engine = MicrosoftRecognizer;
                this.recognizers[i].engine.init(this.recognizers[i].subscriptionKey);
            }
        }

        for(i=0; i<this.synthesizers.length; i++) {
            if(this.synthesizers[i].name.toLowerCase() === 'iflytek') {
                this.synthesizers[i].engine = IflytekSynthesizer;
                this.synthesizers[i].engine.init(this.synthesizers[i].appId);
            }
            else if(this.synthesizers[i].name.toLowerCase() === 'baidu') {
                this.synthesizers[i].engine = BaiduSynthesizer;
                this.synthesizers[i].engine.init(this.synthesizers[i].appId,
                    this.synthesizers[i].appKey, this.synthesizers[i].secretKey);
            }
            else if(this.synthesizers[i].name.toLowerCase() === 'microsoft') {
                this.synthesizers[i].engine = MicrosoftSynthesizer;
                this.synthesizers[i].engine.init(this.synthesizers[i].subscriptionKey);
            }
        }

    }

    startRecognizer(langCode) {
        let code = langCode.toLowerCase();
        let i  = 0;
        let j = 0;
        for(i=0; i<this.recognizers.length; i++) {
            let lanauges = this.recognizers[i].lanauges;
            for(j=0; j<lanauges.length; j++) {
                if(code === lanauges[j].code.toLowerCase()) {
                    this.currentRecognizer = i;
                    this.recognizers[i].engine.start(lanauges[j].value);
                    return;
                }
            }
        }
    }

    stopRecognizer() {
        if(this.currentRecognizer >=0 && this.currentRecognizer < this.recognizers.length) {
            this.recognizers[this.currentRecognizer].engine.stop();
        }
    }

    cancelRecognizer() {
        if(this.currentRecognizer >=0 && this.currentRecognizer < this.recognizers.length) {
            this.recognizers[this.currentRecognizer].engine.cancel();
        }
    }

    isRecognizerListen() {
        if(this.currentRecognizer >=0 && this.currentRecognizer < this.recognizers.length) {
            return this.recognizers[this.currentRecognizer].engine.isListening();
        }
        return false;
    }

    startSynthesizer(content, langCode, pronounce) {
        let code = langCode.toLowerCase();
        let i=0;
        let j=0;
        for(i=0; i<this.synthesizers.length; i++) {
            let lanauges = this.synthesizers[i].lanauges;
            for(j=0; j<lanauges.length; j++) {
                if(code === lanauges[j].code.toLowerCase()) {
                    this.currentRecognizer = i;
                    let speaker = (pronounce == 0 ? lanauges[j].voices.female : lanauges[j].voices.male);
                    this.synthesizers[i].engine.start(content, langCode, pronounce, speaker);
                    return;
                }
            }
        }
    }

    stopSynthesizer() {
        if(this.currentSynthesizer >=0 && this.currentSynthesizer < this.synthesizers.length) {
            this.synthesizers[this.currentSynthesizer].engine.stop();
        }
    }

    isSynthesizerSpeaking() {
        if(this.currentSynthesizer >=0 && this.currentSynthesizer < this.synthesizers.length) {
            return this.synthesizers[this.currentSynthesizer].engine.isSpeaking();
        }

        return false;
    }
}