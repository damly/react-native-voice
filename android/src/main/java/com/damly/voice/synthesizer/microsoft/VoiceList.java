package com.damly.voice.synthesizer.microsoft;

import java.util.ArrayList;

/**
 * Created by damly on 2018/1/12.
 */

public class VoiceList {
    ArrayList<Voice> mArrayList = new ArrayList<>();

    public Voice find(String langCode, int pronounce) {

        Voice.Gender gender = pronounce == 0 ? Voice.Gender.Female : Voice.Gender.Male;

        ArrayList<Voice> array = new ArrayList<>();

        for (Voice voice : mArrayList) {
            if (langCode.toLowerCase().equals(voice.lang.toLowerCase())) {
                array.add(voice);
            }
        }

        if (array.size() == 0) {
            return null;
        }
        for (Voice voice : array) {
            if (voice.gender == gender) {
                return voice;
            }
        }

        return array.get(0);
    }

    public boolean isSupport(String langCode) {
        for (Voice voice : mArrayList) {
            if (langCode.toLowerCase().equals(voice.lang.toLowerCase())) {
                return true;
            }
        }

        return false;
    }

    public VoiceList() {
        mArrayList.add(new Voice("ar-EG", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (ar-EG, Hoda)"));
        mArrayList.add(new Voice("ar-SA", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (ar-SA, Naayf)"));
        mArrayList.add(new Voice("ca-ES", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (ca-ES, HerenaRUS)"));
        mArrayList.add(new Voice("cs-CZ", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (cs-CZ, Vit)"));
        mArrayList.add(new Voice("da-DK", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (da-DK, HelleRUS)"));
        mArrayList.add(new Voice("de-AT", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (de-AT, Michael)"));
        mArrayList.add(new Voice("de-CH", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (de-CH, Karsten)"));
        mArrayList.add(new Voice("de-DE", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (de-DE, Hedda)"));
        mArrayList.add(new Voice("de-DE", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (de-DE, HeddaRUS)"));
        mArrayList.add(new Voice("de-DE", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (de-DE, Stefan, Apollo)"));
        mArrayList.add(new Voice("el-GR", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (el-GR, Stefanos)"));
        mArrayList.add(new Voice("en-AU", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (en-AU, Catherine)"));
        mArrayList.add(new Voice("en-AU", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (en-AU, HayleyRUS)"));
        mArrayList.add(new Voice("en-CA", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (en-CA, Linda)"));
        mArrayList.add(new Voice("en-CA", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (en-CA, HeatherRUS)"));
        mArrayList.add(new Voice("en-GB", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (en-GB, Susan, Apollo)"));
        mArrayList.add(new Voice("en-GB", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (en-GB, HazelRUS)"));
        mArrayList.add(new Voice("en-GB", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (en-GB, George, Apollo)"));
        mArrayList.add(new Voice("en-IE", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (en-IE, Shaun)"));
        mArrayList.add(new Voice("en-IN", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (en-IN, Heera, Apollo)"));
        mArrayList.add(new Voice("en-IN", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (en-IN, PriyaRUS)"));
        mArrayList.add(new Voice("en-IN", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (en-IN, Ravi, Apollo)"));
        mArrayList.add(new Voice("en-US", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (en-US, ZiraRUS)"));
        mArrayList.add(new Voice("en-US", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (en-US, JessaRUS)"));
        mArrayList.add(new Voice("en-US", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (en-US, BenjaminRUS)"));
        mArrayList.add(new Voice("es-ES", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (es-ES, Laura, Apollo)"));
        mArrayList.add(new Voice("es-ES", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (es-ES, HelenaRUS)"));
        mArrayList.add(new Voice("es-ES", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (es-ES, Pablo, Apollo)"));
        mArrayList.add(new Voice("es-MX", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (es-MX, HildaRUS)"));
        mArrayList.add(new Voice("es-MX", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (es-MX, Raul, Apollo)"));
        mArrayList.add(new Voice("fi-FI", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (fi-FI, HeidiRUS)"));
        mArrayList.add(new Voice("fr-CA", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (fr-CA, Caroline)"));
        mArrayList.add(new Voice("fr-CA", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (fr-CA, HarmonieRUS)"));
        mArrayList.add(new Voice("fr-CH", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (fr-CH, Guillaume)"));
        mArrayList.add(new Voice("fr-FR", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (fr-FR, Julie, Apollo)"));
        mArrayList.add(new Voice("fr-FR", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (fr-FR, HortenseRUS)"));
        mArrayList.add(new Voice("fr-FR", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (fr-FR, Paul, Apollo)"));
        mArrayList.add(new Voice("he-IL", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (he-IL, Asaf)"));
        mArrayList.add(new Voice("hi-IN", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (hi-IN, Kalpana, Apollo)"));
        mArrayList.add(new Voice("hi-IN", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (hi-IN, Kalpana)"));
        mArrayList.add(new Voice("hi-IN", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (hi-IN, Hemant)"));
        mArrayList.add(new Voice("hu-HU", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (hu-HU, Szabolcs)"));
        mArrayList.add(new Voice("id-ID", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (id-ID, Andika)"));
        mArrayList.add(new Voice("it-IT", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (it-IT, Cosimo, Apollo)"));
        mArrayList.add(new Voice("ja-JP", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (ja-JP, Ayumi, Apollo)"));
        mArrayList.add(new Voice("ja-JP", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (ja-JP, Ichiro, Apollo)"));
        mArrayList.add(new Voice("ja-JP", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (ja-JP, HarukaRUS)"));
        mArrayList.add(new Voice("ja-JP", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (ja-JP, LuciaRUS)"));
        mArrayList.add(new Voice("ja-JP", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (ja-JP, EkaterinaRUS)"));
        mArrayList.add(new Voice("ko-KR", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (ko-KR, HeamiRUS)"));
        mArrayList.add(new Voice("nb-NO", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (nb-NO, HuldaRUS)"));
        mArrayList.add(new Voice("nl-NL", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (nl-NL, HannaRUS)"));
        mArrayList.add(new Voice("pl-PL", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (pl-PL, PaulinaRUS)"));
        mArrayList.add(new Voice("pt-BR", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (pt-BR, HeloisaRUS)"));
        mArrayList.add(new Voice("pt-BR", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (pt-BR, Daniel, Apollo)"));
        mArrayList.add(new Voice("pt-PT", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (pt-PT, HeliaRUS)"));
        mArrayList.add(new Voice("ro-RO", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (ro-RO, Andrei)"));
        mArrayList.add(new Voice("ru-RU", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (ru-RU, Irina, Apollo)"));
        mArrayList.add(new Voice("ru-RU", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (ru-RU, Pavel, Apollo)"));
        mArrayList.add(new Voice("sk-SK", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (sk-SK, Filip)"));
        mArrayList.add(new Voice("sv-SE", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (sv-SE, HedvigRUS)"));
        mArrayList.add(new Voice("th-TH", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (th-TH, Pattara)"));
        mArrayList.add(new Voice("tr-TR", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (tr-TR, SedaRUS)"));
        mArrayList.add(new Voice("zh-CN", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (zh-CN, HuihuiRUS)"));
        mArrayList.add(new Voice("zh-CN", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (zh-CN, Yaoyao, Apollo)"));
        mArrayList.add(new Voice("zh-CN", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (zh-CN, Kangkang, Apollo)"));
        mArrayList.add(new Voice("zh-HK", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (zh-HK, Tracy, Apollo)"));
        mArrayList.add(new Voice("zh-HK", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (zh-HK, TracyRUS)"));
        mArrayList.add(new Voice("zh-HK", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (zh-HK, Danny, Apollo)"));
        mArrayList.add(new Voice("zh-TW", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (zh-TW, Yating, Apollo)"));
        mArrayList.add(new Voice("zh-TW", Voice.Gender.Female, "Microsoft Server Speech Text to Speech Voice (zh-TW, HanHanRUS)"));
        mArrayList.add(new Voice("zh-TW", Voice.Gender.Male, "Microsoft Server Speech Text to Speech Voice (zh-TW, Zhiwei, Apollo)"));
    }
}
