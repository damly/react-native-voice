/**
 * Created by damly on 2018/1/17.
 */

const recognizers = [
    {
        name: 'iflytek',
        appId: '',
        lanauges: [
            {code: "zh", value: "zh_cn"},
            {code: "zh-CN", value: "zh_cn"},
            {code: "zh-HK", value: "zh_hk"},
            {code: "zh-TW", value: "zh_cn"},
            {code: "en", value: "en_us"},
            {code: "en-GB", value: "en_us"},
            {code: "en-US", value: "en_us"}
        ]
    },
    {
        name: 'baidu',
        appId: '',
        appKey: '',
        secretKey: '',
        lanauges: [
            {code: "zh", value: "zh"},
            {code: "zh-CN", value: "zh"},
            {code: "zh-HK", value: "ct"},
            {code: "zh-TW", value: "zh"},
            {code: "en", value: "en"},
            {code: "en-GB", value: "en"},
            {code: "en-US", value: "en"}
        ]
    },
    {
        name: 'microsoft',
        subscriptionKey: '',
        lanauges: [
            {code:"zh", value: "zh-CN"},
            {code:"zh-CN", value: "zh-CN"},
            {code:"zh-HK", value: "zh-HK"},
            {code:"zh-TW", value: "zh-TW"},
            {code:"en", value: "en-US"},
            {code:"en-AU", value: "en-AU"},
            {code:"en-CA", value: "en-CA"},
            {code:"en-GB", value: "en-GB"},
            {code:"en-IN", value: "en-IN"},
            {code:"en-NZ", value: "en-NZ"},
            {code:"en-US", value: "en-US"},
            {code:"es-ES", value: "es-ES"},
            {code:"en-MX", value: "en-MX"},
            {code:"es-MX", value: "es-MX"},
            {code:"ar-EG", value: "ar-EG"},
            {code:"ca-ES", value: "ca-ES"},
            {code:"da-DK", value: "da-DK"},
            {code:"fi-FI", value: "fi-FI"},
            {code:"fr-CA", value: "fr-CA"},
            {code:"fr-FR", value: "fr-FR"},
            {code:"hi-IN", value: "hi-IN"},
            {code:"it-IT", value: "it-IT"},
            {code:"ja-JP", value: "ja-JP"},
            {code:"ko-KR", value: "ko-KR"},
            {code:"nb-NO", value: "nb-NO"},
            {code:"nl-NL", value: "nl-NL"},
            {code:"pl-PL", value: "pl-PL"},
            {code:"pt-BR", value: "pt-BR"},
            {code:"pt-PT", value: "pt-PT"},
            {code:"ru-RU", value: "ru-RU"},
            {code:"sv-SE", value: "sv-SE"}
        ]
    },
];

const synthesizers = [
    {
        name: 'baidu',
        appId: '',
        appKey: '',
        secretKey: '',
        lanauges: [
            {code: "zh", voices: {female: "0", male: "1"}},
            {code: "zh-CN", voices: {female: "0", male: "1"}},
            {code: "zh-HK", voices: {female: "0", male: "1"}},
            {code: "zh-TW", voices: {female: "0", male: "1"}},
            {code: "en", voices: {female: "0", male: "1"}},
            {code: "en-GB", voices: {female: "0", male: "1"}},
            {code: "en-US", voices: {female: "0", male: "1"}},
            {code: "fr-FR", voices: {female: "0", male: "1"}},
            {code: "ru-RU", voices: {female: "0", male: "1"}},
            {code: "es-ES", voices: {female: "0", male: "1"}},
            {code: "hi-IN", voices: {female: "0", male: "1"}},
            {code: "vi-VN", voices: {female: "0", male: "1"}},
        ]
    },
    {
        name: 'iflytek',
        appId: '',
        lanauges: [
            {code: "zh", voices: {female: "xiaoyan", male: "xiaoyu"}},
            {code: "zh-CN", voices: {female: "xiaoyan", male: "xiaoyu"}},
            {code: "zh-HK", voices: {female: "xiaomei", male: "xiaomei"}},
            {code: "zh-TW", voices: {female: "xiaolin", male: "xiaolin"}},
            {code: "en", voices: {female: "catherine", male: "henry"}},
            {code: "en-GB", voices: {female: "catherine", male: "henry"}},
            {code: "en-US", voices: {female: "catherine", male: "henry"}},
            {code: "fr-FR", voices: {female: "Mariane", male: "Mariane"}},
            {code: "ru-RU", voices: {female: "Allabent", male: "Allabent"}},
            {code: "es-ES", voices: {female: "Gabriela", male: "Gabriela"}},
            {code: "hi-IN", voices: {female: "Abha", male: "Abha"}},
            {code: "vi-VN", voices: {female: "XiaoYun", male: "XiaoYun"}},
        ]
    },
    {
        name: 'microsoft',
        subscriptionKey: '',
        lanauges: [
            {code:'ar-EG', voices:{female: 'Microsoft Server Speech Text to Speech Voice (ar-EG, Hoda)', male: 'Microsoft Server Speech Text to Speech Voice (ar-EG, Hoda)'}},
            {code:'ar-SA', voices:{female: 'Microsoft Server Speech Text to Speech Voice (ar-SA, Naayf)', male: 'Microsoft Server Speech Text to Speech Voice (ar-SA, Naayf)'}},
            {code:'ca-ES', voices:{female: 'Microsoft Server Speech Text to Speech Voice (ca-ES, HerenaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (ca-ES, HerenaRUS)'}},
            {code:'cs-CZ', voices:{female: 'Microsoft Server Speech Text to Speech Voice (cs-CZ, Vit)', male: 'Microsoft Server Speech Text to Speech Voice (cs-CZ, Vit)'}},
            {code:'da-DK', voices:{female: 'Microsoft Server Speech Text to Speech Voice (da-DK, HelleRUS)', male: 'Microsoft Server Speech Text to Speech Voice (da-DK, HelleRUS)'}},
            {code:'de-AT', voices:{female: 'Microsoft Server Speech Text to Speech Voice (de-AT, Michael)', male: 'Microsoft Server Speech Text to Speech Voice (de-AT, Michael)'}},
            {code:'de-CH', voices:{female: 'Microsoft Server Speech Text to Speech Voice (de-CH, Karsten)', male: 'Microsoft Server Speech Text to Speech Voice (de-CH, Karsten)'}},
            {code:'de-DE', voices:{female: 'Microsoft Server Speech Text to Speech Voice (de-DE, HeddaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (de-DE, Stefan, Apollo)'}},
            {code:'el-GR', voices:{female: 'Microsoft Server Speech Text to Speech Voice (el-GR, Stefanos)', male: 'Microsoft Server Speech Text to Speech Voice (el-GR, Stefanos)'}},
            {code:'en', voices:{female: 'Microsoft Server Speech Text to Speech Voice (en-US, ZiraRUS)', male: 'Microsoft Server Speech Text to Speech Voice (en-US, BenjaminRUS)'}},
            {code:'en-AU', voices:{female: 'Microsoft Server Speech Text to Speech Voice (en-AU, Catherine)', male: 'Microsoft Server Speech Text to Speech Voice (en-AU, Catherine)'}},
            {code:'en-AU', voices:{female: 'Microsoft Server Speech Text to Speech Voice (en-AU, HayleyRUS)', male: 'Microsoft Server Speech Text to Speech Voice (en-AU, HayleyRUS)'}},
            {code:'en-CA', voices:{female: 'Microsoft Server Speech Text to Speech Voice (en-CA, Linda)', male: 'Microsoft Server Speech Text to Speech Voice (en-CA, Linda)'}},
            {code:'en-GB', voices:{female: 'Microsoft Server Speech Text to Speech Voice (en-GB, HazelRUS)', male: 'Microsoft Server Speech Text to Speech Voice (en-GB, George, Apollo)'}},
            {code:'en-IE', voices:{female: 'Microsoft Server Speech Text to Speech Voice (en-IE, Shaun)', male: 'Microsoft Server Speech Text to Speech Voice (en-IE, Shaun)'}},
            {code:'en-IN', voices:{female: 'Microsoft Server Speech Text to Speech Voice (en-IN, PriyaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (en-IN, Ravi, Apollo)'}},
            {code:'en-US', voices:{female: 'Microsoft Server Speech Text to Speech Voice (en-US, ZiraRUS)', male: 'Microsoft Server Speech Text to Speech Voice (en-US, BenjaminRUS)'}},
            {code:'es-ES', voices:{female: 'Microsoft Server Speech Text to Speech Voice (es-ES, HelenaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (es-ES, Pablo, Apollo)'}},
            {code:'es-MX', voices:{female: 'Microsoft Server Speech Text to Speech Voice (es-MX, HildaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (es-MX, Raul, Apollo)'}},
            {code:'fi-FI', voices:{female: 'Microsoft Server Speech Text to Speech Voice (fi-FI, HeidiRUS)', male: 'Microsoft Server Speech Text to Speech Voice (fi-FI, HeidiRUS)'}},
            {code:'fr-CA', voices:{female: 'Microsoft Server Speech Text to Speech Voice (fr-CA, Caroline)', male: 'Microsoft Server Speech Text to Speech Voice (fr-CA, Caroline)'}},
            {code:'fr-CH', voices:{female: 'Microsoft Server Speech Text to Speech Voice (fr-CH, Guillaume)', male: 'Microsoft Server Speech Text to Speech Voice (fr-CH, Guillaume)'}},
            {code:'fr-FR', voices:{female: 'Microsoft Server Speech Text to Speech Voice (fr-FR, HortenseRUS)', male: 'Microsoft Server Speech Text to Speech Voice (fr-FR, Paul, Apollo)'}},
            {code:'he-IL', voices:{female: 'Microsoft Server Speech Text to Speech Voice (he-IL, Asaf)', male: 'Microsoft Server Speech Text to Speech Voice (he-IL, Asaf)'}},
            {code:'hi-IN', voices:{female: 'Microsoft Server Speech Text to Speech Voice (hi-IN, Kalpana, Apollo)', male: 'Microsoft Server Speech Text to Speech Voice (hi-IN, Hemant)'}},
            {code:'hu-HU', voices:{female: 'Microsoft Server Speech Text to Speech Voice (hu-HU, Szabolcs)', male: 'Microsoft Server Speech Text to Speech Voice (hu-HU, Szabolcs)'}},
            {code:'id-ID', voices:{female: 'Microsoft Server Speech Text to Speech Voice (id-ID, Andika)', male: 'Microsoft Server Speech Text to Speech Voice (id-ID, Andika)'}},
            {code:'it-IT', voices:{female: 'Microsoft Server Speech Text to Speech Voice (it-IT, Cosimo, Apollo)', male: 'Microsoft Server Speech Text to Speech Voice (it-IT, Cosimo, Apollo)'}},
            {code:'ja-JP', voices:{female: 'Microsoft Server Speech Text to Speech Voice (ja-JP, LuciaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (ja-JP, EkaterinaRUS)'}},
            {code:'ko-KR', voices:{female: 'Microsoft Server Speech Text to Speech Voice (ko-KR, HeamiRUS)', male: 'Microsoft Server Speech Text to Speech Voice (ko-KR, HeamiRUS)'}},
            {code:'nb-NO', voices:{female: 'Microsoft Server Speech Text to Speech Voice (nb-NO, HuldaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (nb-NO, HuldaRUS)'}},
            {code:'nl-NL', voices:{female: 'Microsoft Server Speech Text to Speech Voice (nl-NL, HannaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (nl-NL, HannaRUS)'}},
            {code:'pl-PL', voices:{female: 'Microsoft Server Speech Text to Speech Voice (pl-PL, PaulinaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (pl-PL, PaulinaRUS)'}},
            {code:'pt-BR', voices:{female: 'Microsoft Server Speech Text to Speech Voice (pt-BR, HeloisaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (pt-BR, Daniel, Apollo)'}},
            {code:'pt-PT', voices:{female: 'Microsoft Server Speech Text to Speech Voice (pt-PT, HeliaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (pt-PT, HeliaRUS)'}},
            {code:'ro-RO', voices:{female: 'Microsoft Server Speech Text to Speech Voice (ro-RO, Andrei)', male: 'Microsoft Server Speech Text to Speech Voice (ro-RO, Andrei)'}},
            {code:'ru-RU', voices:{female: 'Microsoft Server Speech Text to Speech Voice (ru-RU, Irina, Apollo)', male: 'Microsoft Server Speech Text to Speech Voice (ru-RU, Pavel, Apollo)'}},
            {code:'sk-SK', voices:{female: 'Microsoft Server Speech Text to Speech Voice (sk-SK, Filip)', male: 'Microsoft Server Speech Text to Speech Voice (sk-SK, Filip)'}},
            {code:'sv-SE', voices:{female: 'Microsoft Server Speech Text to Speech Voice (sv-SE, HedvigRUS)', male: 'Microsoft Server Speech Text to Speech Voice (sv-SE, HedvigRUS)'}},
            {code:'th-TH', voices:{female: 'Microsoft Server Speech Text to Speech Voice (th-TH, Pattara)', male: 'Microsoft Server Speech Text to Speech Voice (th-TH, Pattara)'}},
            {code:'tr-TR', voices:{female: 'Microsoft Server Speech Text to Speech Voice (tr-TR, SedaRUS)', male: 'Microsoft Server Speech Text to Speech Voice (tr-TR, SedaRUS)'}},
            {code:'zh', voices:{female: 'Microsoft Server Speech Text to Speech Voice (zh-CN, HuihuiRUS)', male: 'Microsoft Server Speech Text to Speech Voice (zh-CN, Kangkang, Apollo)'}},
            {code:'zh-CN', voices:{female: 'Microsoft Server Speech Text to Speech Voice (zh-CN, HuihuiRUS)', male: 'Microsoft Server Speech Text to Speech Voice (zh-CN, Kangkang, Apollo)'}},
            {code:'zh-HK', voices:{female: 'Microsoft Server Speech Text to Speech Voice (zh-HK, TracyRUS)', male: 'Microsoft Server Speech Text to Speech Voice (zh-HK, Danny, Apollo)'}},
            {code:'zh-TW', voices:{female: 'Microsoft Server Speech Text to Speech Voice (zh-TW, HanHanRUS)', male: 'Microsoft Server Speech Text to Speech Voice (zh-TW, Zhiwei, Apollo)'}},
        ]
    },


];

module.exports = {recognizers,  synthesizers};
