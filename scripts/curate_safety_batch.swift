#!/usr/bin/env swift

import Foundation

// Human-reviewed safety and remembrance batch, checked on 2026-08-14.
// The script is deliberately explicit and refuses to curate an unknown record.

private struct LocalizedDay: Codable {
    let id: String
    let month: Int
    let day: Int
    var title: String
    var description: String
    var emoji: String
    var category: String
    var sharingHook: String
}

private struct CopyPatch {
    let id: String
    let trDescription: String
    let trHook: String
    let enDescription: String
    let enHook: String
}

private struct SourcePatch {
    let organization: String
    let url: String
}

private let copy: [CopyPatch] = [
    .init(id: "01-27", trDescription: "Hatırlamak geçmişte kalmak değildir; antisemitizmin, nefretin ve insanlıktan çıkarmanın bugünkü biçimlerini de fark etmektir.", trHook: "Hafızayı canlı tutmak için saygıyla paylaş", enDescription: "Remembrance is not only about the past; it also means recognizing antisemitism, hatred and dehumanization today.", enHook: "Share with care to keep memory alive"),
    .init(id: "02-06", trDescription: "Kadın genital mutilasyonu sağlık sorunu olmanın yanında, kız çocukları ve kadınlara yönelik bir insan hakları ihlalidir.", trHook: "Doğru bilgiyle ve mağdurları gözeterek paylaş", enDescription: "Female genital mutilation is both a serious health issue and a violation of the human rights of girls and women.", enHook: "Share accurate information with survivors in mind"),
    .init(id: "02-12", trDescription: "Şiddet içeren aşırıcılıkla mücadele, korkuyu büyütmeden insan haklarını, eğitimi ve toplumsal dayanışmayı güçlendirmeyi gerektirir.", trHook: "Korkuyu değil dayanışmayı büyütmek için paylaş", enDescription: "Preventing violent extremism means strengthening human rights, education and social cohesion without amplifying fear.", enHook: "Share to strengthen solidarity, not fear"),
    .init(id: "03-01", trDescription: "Hiç kimse kimliği, görünüşü, sağlığı ya da yaşam koşulları nedeniyle daha az hakka sahip değildir.", trHook: "Ayrımcılığa karşı ses vermek için paylaş", enDescription: "No one deserves fewer rights because of their identity, appearance, health or circumstances.", enHook: "Share to speak up against discrimination"),
    .init(id: "03-05", trDescription: "Silahların yayılmasını önlemek yalnızca devletlerin değil, güvenli bir gelecek isteyen herkesin meselesidir.", trHook: "Barış ve güvenlik için bağlamıyla paylaş", enDescription: "Preventing the spread of weapons concerns everyone who wants a safer future, not only governments.", enHook: "Share with context for peace and security"),
    .init(id: "03-15", trDescription: "İslamofobiyle mücadele; önyargıya, nefrete ve Müslümanlara yönelik ayrımcılığa sessiz kalmamayı gerektirir.", trHook: "Nefrete karşı dayanışmayla paylaş", enDescription: "Combating Islamophobia means refusing to stay silent about prejudice, hatred and discrimination against Muslims.", enHook: "Share in solidarity against hatred"),
    .init(id: "03-24", trDescription: "Tüberküloz önlenebilir ve tedavi edilebilir; doğru bilgiye, erken tanıya ve sağlık hizmetlerine erişim hayat kurtarır.", trHook: "Güvenilir sağlık bilgisiyle paylaş", enDescription: "Tuberculosis is preventable and curable; access to reliable information, early diagnosis and care saves lives.", enHook: "Share with reliable health information"),
    .init(id: "03-25", trDescription: "Köleleştirilen milyonlarca insanı anmak, köleliğin mirasının bugünkü eşitsizliklerde nasıl sürdüğünü de görmeyi gerektirir.", trHook: "Tarihi ve bugünkü mirasını saygıyla paylaş", enDescription: "Remembering millions of enslaved people also means seeing how slavery's legacy continues through inequality today.", enHook: "Share its history and continuing legacy with care"),
    .init(id: "03-26", trDescription: "Mor Gün, epilepsiyle yaşayanların deneyimlerini görünür kılmak, yanlış inanışları azaltmak ve desteği büyütmek için bir çağrı.", trHook: "Epilepsi topluluğunun sesini özenle büyüt", enDescription: "Purple Day calls attention to lived experience with epilepsy, challenges myths and grows support for the community.", enHook: "Amplify the epilepsy community with care"),
    .init(id: "04-02", trDescription: "Otistik bireyleri yalnızca fark etmek değil; dinlemek, farklı iletişim biçimlerine alan açmak ve kapsayıcılığı büyütmek önemli.", trHook: "Otistik bireyleri dinleyerek paylaş", enDescription: "It is not enough to notice autistic people; listening, respecting different communication and building inclusion matter.", enHook: "Share by centering autistic voices"),
    .init(id: "04-04", trDescription: "Mayınlar çatışma bittikten yıllar sonra bile siviller için tehdit olmaya devam eder; temizleme çalışmaları ve mağdur desteği hayat kurtarır.", trHook: "Sivilleri ve çözüm çalışmalarını gözeterek paylaş", enDescription: "Landmines can threaten civilians long after conflict ends; mine clearance and victim assistance save lives.", enHook: "Share with civilians and solutions in focus"),
    .init(id: "04-07", trDescription: "Dünya Sağlık Günü, herkesin nitelikli sağlık hizmetine ayrımcılık ve maddi engel olmadan erişebilmesi gerektiğini hatırlatır.", trHook: "Sağlık hakkını güvenilir bilgiyle paylaş", enDescription: "World Health Day is a reminder that everyone should be able to reach quality health care without discrimination or financial barriers.", enHook: "Share the right to health with reliable context"),
    .init(id: "04-11", trDescription: "Parkinson tek tip yaşanmaz; yaşayanları ve bakım verenleri dinlemek, belirtiler kadar gündelik deneyimi de anlamaya yardımcı olur.", trHook: "Yaşayanların deneyimini merkeze alarak paylaş", enDescription: "Parkinson's is not experienced in one single way; listening to people and care partners reveals the daily reality beyond symptoms.", enHook: "Share by centering lived experience"),
    .init(id: "04-17", trDescription: "Hemofili ve diğer kalıtsal kanama bozukluklarında tanıya, uygun bakıma ve tedaviye erişim yaşam kalitesini doğrudan etkiler.", trHook: "Güvenilir bilgi ve bakım erişimi için paylaş", enDescription: "For haemophilia and other inherited bleeding disorders, access to diagnosis, appropriate care and treatment directly affects quality of life.", enHook: "Share for reliable information and access to care"),
    .init(id: "04-25", trDescription: "Sıtma önlenebilir ve tedavi edilebilir; korunma araçlarına, tanıya ve etkili tedaviye eşit erişim belirleyicidir.", trHook: "Doğrulanmış sağlık bilgisiyle paylaş", enDescription: "Malaria is preventable and curable; equitable access to prevention, diagnosis and effective treatment is essential.", enHook: "Share with verified health information"),
    .init(id: "04-29", trDescription: "Depremlerde hayatını kaybedenleri anmak, güvenli yapılar ve hazırlık konusunda ortak sorumluluğumuzu da hatırlatır.", trHook: "Hafıza ve hazırlık için saygıyla paylaş", enDescription: "Remembering people lost to earthquakes also recalls our shared responsibility for safer buildings and preparedness.", enHook: "Share with care for remembrance and preparedness"),
    .init(id: "05-08", trDescription: "İkinci Dünya Savaşı'nda hayatını kaybedenleri anmak, barışın korunması için hafıza ve iş birliğinin değerini hatırlatır.", trHook: "Barışın hafızasını saygıyla paylaş", enDescription: "Remembering those lost in the Second World War underlines the value of memory and cooperation in protecting peace.", enHook: "Share the memory of peace with care"),
    .init(id: "05-28", trDescription: "Adet sağlığı hakkında açık ve doğru konuşmak; damgalamayı azaltır, güvenli ürünlere, suya ve sağlık hizmetlerine erişimi görünür kılar.", trHook: "Tabuları değil doğru bilgiyi çoğalt", enDescription: "Open, accurate conversation about menstrual health reduces stigma and highlights access to safe products, water and health care.", enHook: "Share accurate information, not stigma"),
    .init(id: "06-04", trDescription: "Savaş ve çatışmanın hiçbir çocuğun güvenliğini, eğitimini ve geleceğini elinden almaması gerektiğini hatırlatıyor.", trHook: "Çocukların güvenliği için özenle paylaş", enDescription: "War and conflict should never take away a child's safety, education or future.", enHook: "Share with care for children's safety"),
    .init(id: "06-12", trDescription: "Her çocuk güvenli bir çocukluk, eğitim ve oyun hakkına sahiptir; ağır ve tehlikeli işlere değil.", trHook: "Çocukların hakları için bağlamıyla paylaş", enDescription: "Every child deserves safety, education and play — not dangerous or exploitative work.", enHook: "Share with context for children's rights"),
    .init(id: "06-15", trDescription: "Yaşlılara yönelik ihmal, ekonomik sömürü ve şiddet çoğu zaman görünmez kalır; fark etmek korumanın ilk adımıdır.", trHook: "Yaşlıların onurunu gözeterek paylaş", enDescription: "Neglect, financial exploitation and violence against older people often remain hidden; noticing is the first step.", enHook: "Share with older people's dignity in focus"),
    .init(id: "06-18", trDescription: "Nefret söylemi yalnızca kelimelerden ibaret değildir; insanları hedef hâline getirir ve birlikte yaşama zeminini aşındırır.", trHook: "Nefreti büyütmeden karşı durmak için paylaş", enDescription: "Hate speech is more than words; it targets people and erodes the ground for living together.", enHook: "Share to challenge hate without amplifying it"),
    .init(id: "06-19", trDescription: "Çatışmalarda cinsel şiddet kaçınılmaz değildir; hayatta kalanların sesi, güvenliği ve adalete erişimi merkeze alınmalıdır.", trHook: "Hayatta kalanları gözeterek, özenle paylaş", enDescription: "Sexual violence in conflict is not inevitable; survivors' voices, safety and access to justice must come first.", enHook: "Share with care and survivors in focus"),
    .init(id: "06-20", trDescription: "Mülteci olmak bir tercih değil; güvenli bir yaşam aramak zorunda kalmaktır. Onur ve haklar sınırda sona ermez.", trHook: "İnsan onurunu merkeze alarak paylaş", enDescription: "Being a refugee is not a choice but a search for safety. Dignity and rights do not end at a border.", enHook: "Share with human dignity at the center"),
    .init(id: "06-26", trDescription: "Uyuşturucu sorununa etkili yanıt; damgalama yerine bilimsel önleme, zarar azaltma, tedavi ve insan haklarını merkeze alır.", trHook: "Damgalamadan, doğrulanmış bilgiyle paylaş", enDescription: "An effective response to drugs centers evidence-based prevention, harm reduction, treatment and human rights instead of stigma.", enHook: "Share verified information without stigma"),
    .init(id: "07-28", trDescription: "Viral hepatit hakkında doğru bilgi, test ve tedaviye erişim ile damgalamadan uzak sağlık hizmetleri hastalığın yükünü azaltır.", trHook: "Güvenilir sağlık kaynaklarıyla paylaş", enDescription: "Accurate information, access to testing and treatment, and stigma-free care reduce the burden of viral hepatitis.", enHook: "Share with reliable health sources"),
    .init(id: "08-02", trDescription: "Nazi döneminde öldürülen Romanları anmak, Romanlara yönelik nefret ve ayrımcılığın bugün de karşısında durmayı gerektirir.", trHook: "Roman hafızasını saygıyla görünür kıl", enDescription: "Remembering Roma murdered under the Nazis also means opposing anti-Roma hatred and discrimination today.", enHook: "Share Roma remembrance with care"),
    .init(id: "08-21", trDescription: "Terör saldırılarından etkilenenlerin kayıplarını, yaşamlarını ve haklarını sayıların ötesinde hatırlama günü.", trHook: "Mağdur ve hayatta kalanları saygıyla an", enDescription: "A day to remember the lives, losses and rights of people affected by terrorism beyond the statistics.", enHook: "Remember victims and survivors with care"),
    .init(id: "08-22", trDescription: "Hiç kimse inancı ya da inançsızlığı nedeniyle şiddetin hedefi olmamalı; vicdan özgürlüğü herkes içindir.", trHook: "İnanç ve vicdan özgürlüğü için saygıyla paylaş", enDescription: "No one should face violence because of belief or non-belief; freedom of conscience belongs to everyone.", enHook: "Share with care for freedom of belief and conscience"),
    .init(id: "08-23", trDescription: "Köle ticaretine direnenleri ve hayatları ellerinden alınanları anmak, özgürlük mücadelesinin hafızasını canlı tutar.", trHook: "Direnişi ve kayıpları saygıyla hatırla", enDescription: "Remembering those who resisted the slave trade and those whose lives were taken keeps the struggle for freedom alive.", enHook: "Remember resistance and loss with care"),
    .init(id: "08-29", trDescription: "Nükleer denemelerin insanlar ve çevre üzerinde bıraktığı uzun süreli zararı hatırlamak, tekrarını önlemenin parçasıdır.", trHook: "Nükleer denemelerin etkisini bağlamıyla paylaş", enDescription: "Remembering the lasting harm of nuclear tests to people and the environment is part of preventing their return.", enHook: "Share the impact of nuclear tests with context"),
    .init(id: "08-30", trDescription: "Zorla kaybedilenlerin aileleri cevap, hakikat ve adalet aramaya devam eder; belirsizlik de başlı başına bir acıdır.", trHook: "Hakikat ve adalet talebini saygıyla paylaş", enDescription: "Families of the forcibly disappeared continue to seek truth and justice; uncertainty is itself a form of suffering.", enHook: "Share the call for truth and justice with care"),
    .init(id: "09-09", trDescription: "Okullar çatışmanın hedefi değil, çocukların güvende öğrenebildiği yerler olmalıdır.", trHook: "Eğitimin güvenliği için özenle paylaş", enDescription: "Schools should never be targets in conflict; they should remain places where children can learn safely.", enHook: "Share with care for safe education"),
    .init(id: "09-10", trDescription: "Bir mesaj her şeyi çözmeyebilir; ama yargısız dinlemek ve profesyonel desteğe ulaşmayı kolaylaştırmak önemlidir.", trHook: "Yargılamadan dinlemeyi ve desteği hatırlat", enDescription: "One message may not solve everything, but listening without judgment and helping someone reach professional support matter.", enHook: "Share a reminder to listen and connect to support"),
    .init(id: "09-11", trDescription: "11 Eylül saldırılarında hayatını kaybedenleri, yakınlarını ve olayın uzun süreli etkilerini saygıyla anma günü.", trHook: "Kayıpları ve yakınlarını saygıyla an", enDescription: "A day to remember those killed in the September 11 attacks, their loved ones and the lasting impact with care.", enHook: "Remember those lost and their loved ones with care"),
    .init(id: "09-17", trDescription: "Hasta güvenliği; önlenebilir zararı azaltmayı, hastaları dinlemeyi ve sağlık çalışanlarıyla açık iletişim kurmayı gerektirir.", trHook: "Güvenli bakım için doğrulanmış bilgiyle paylaş", enDescription: "Patient safety means reducing preventable harm, listening to patients and supporting open communication with health workers.", enHook: "Share verified information for safer care"),
    .init(id: "10-10", trDescription: "Ruh sağlığı da sağlıktır; damgalamadan konuşmak ve ihtiyaç olduğunda profesyonel desteğe erişebilmek önemlidir.", trHook: "Yargısız ve güvenilir bir dille paylaş", enDescription: "Mental health is health; speaking without stigma and being able to reach professional support when needed both matter.", enHook: "Share in reliable, stigma-free language"),
    .init(id: "10-18", trDescription: "Menopoz deneyimi kişiden kişiye değişir; güvenilir bilgi, uygun sağlık desteği ve açık iletişim bu dönemi kolaylaştırabilir.", trHook: "Güvenilir bilgiyle ve deneyimleri gözeterek paylaş", enDescription: "Menopause differs from person to person; reliable information, appropriate health support and open conversation can help.", enHook: "Share reliable information with lived experience in mind"),
    .init(id: "10-20", trDescription: "Kemik sağlığı yaşam boyu önem taşır; riskleri bilmek, uygun değerlendirme ve tedaviye erişmek kırıkları önlemeye yardımcı olabilir.", trHook: "Kemik sağlığı bilgisini güvenilir kaynakla paylaş", enDescription: "Bone health matters throughout life; knowing risks and reaching appropriate assessment and treatment can help prevent fractures.", enHook: "Share bone-health information from reliable sources"),
    .init(id: "10-02", trDescription: "2 Ekim, Mahatma Gandhi'nin doğum gününde; çatışma ve adaletsizliğe şiddete başvurmadan karşı koymanın gücünü hatırlatır.", trHook: "Barışçıl değişime inanan birine gönder", enDescription: "Observed on Mahatma Gandhi's birthday, 2 October highlights the power of confronting conflict and injustice without violence.", enHook: "Send to someone who believes in peaceful change"),
    .init(id: "11-12", trDescription: "Zatürre önlenebilir ve tedavi edilebilir; aşıya, erken tanıya, uygun tedaviye ve gerektiğinde oksijene erişim hayat kurtarır.", trHook: "Doğrulanmış sağlık bilgisiyle paylaş", enDescription: "Pneumonia is preventable and treatable; access to vaccination, early diagnosis, appropriate treatment and oxygen when needed saves lives.", enHook: "Share with verified health information"),
    .init(id: "11-14", trDescription: "Diyabetle yaşamak sürekli karar ve bakım gerektirir; doğru bilgiye, tanıya, insüline ve düzenli sağlık hizmetine erişim kritiktir.", trHook: "Diyabet hakkında güvenilir bilgiyle paylaş", enDescription: "Living with diabetes requires continuous decisions and care; access to accurate information, diagnosis, insulin and regular health services is critical.", enHook: "Share reliable information about diabetes"),
    .init(id: "11-15", trDescription: "Sınıraşan örgütlü suç; insan ticareti, silah ve uyuşturucu kaçakçılığı gibi yollarla insanları sömürür, toplumları ve hukukun üstünlüğünü zayıflatır.", trHook: "Konuyu büyütmeden, doğrulanmış bağlamla paylaş", enDescription: "Transnational organized crime exploits people through trafficking in persons, weapons and drugs while weakening communities and the rule of law.", enHook: "Share with verified context, without sensationalism"),
    .init(id: "11-17", trDescription: "WhaDay takviminden küçük bir dürtü: uzun zamandır yazmayı düşündüğün kişiye ilk mesajı bugün sen at.", trHook: "Uzun zamandır yazmadığın kişiye gönder", enDescription: "A small nudge from the WhaDay calendar: send the first message to someone you have been meaning to text.", enHook: "Send to someone you've been meaning to text"),
    .init(id: "11-18", trDescription: "Çocuklara yönelik cinsel istismarı önlemek; güvenli alanlar kurmayı, çocukları dinlemeyi ve sorumluluğu yetişkinlerin almasını gerektirir.", trHook: "Çocukların güvenliğini merkeze alarak paylaş", enDescription: "Preventing child sexual abuse requires safe environments, listening to children and adults taking responsibility.", enHook: "Share with children's safety at the center"),
    .init(id: "11-25", trDescription: "Kadınlara yönelik şiddet özel bir mesele değil, önlenebilir bir insan hakları ihlalidir.", trHook: "Şiddete karşı, mağdurları gözeterek paylaş", enDescription: "Violence against women is not a private matter; it is a preventable human rights violation.", enHook: "Share against violence with survivors in mind"),
    .init(id: "11-30", trDescription: "Kimyasal silah mağdurlarını anmak, bu silahların hiçbir koşulda yeniden kullanılmaması gerektiğini hatırlatır.", trHook: "Mağdurları saygıyla anmak için paylaş", enDescription: "Remembering victims of chemical warfare reinforces that these weapons must never be used again.", enHook: "Share to remember victims with care"),
    .init(id: "12-02", trDescription: "Kölelik geçmişte kalmış tek bir düzen değil; zorla çalıştırma ve insan ticareti gibi biçimlerle mücadele bugün de sürüyor.", trHook: "Günümüzdeki sömürü biçimlerini bağlamıyla paylaş", enDescription: "Slavery is not only a system from the past; the fight continues against forced labour and human trafficking today.", enHook: "Share today's forms of exploitation with context"),
    .init(id: "12-10", trDescription: "İnsan hakları yalnızca bazı insanlar için ya da iyi zamanlarda geçerli değildir; herkes için ve her gün gereklidir.", trHook: "Hakların herkes için olduğunu hatırlat", enDescription: "Human rights are not only for some people or for easy times; they belong to everyone, every day.", enHook: "Share the reminder that rights belong to everyone"),
    .init(id: "12-12", trDescription: "Evrensel sağlık güvencesi, herkesin ihtiyaç duyduğu nitelikli sağlık hizmetine maddi zorluk yaşamadan erişebilmesi demektir.", trHook: "Sağlık hizmetine eşit erişim için paylaş", enDescription: "Universal health coverage means everyone can access the quality health services they need without financial hardship.", enHook: "Share for equitable access to health care")
]

private let sources: [String: SourcePatch] = [
    "01-27": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/holocaust-remembrance"),
    "02-06": .init(organization: "United Nations", url: "https://www.un.org/en/observances/international-day-zero-tolerance-female-genital-mutilation"),
    "02-12": .init(organization: "United Nations", url: "https://www.un.org/en/observances/prevention-extremism-when-conducive-terrorism-day"),
    "03-01": .init(organization: "United Nations / UNAIDS", url: "https://www.un.org/en/observances/zero-discrimination-day"),
    "03-05": .init(organization: "United Nations", url: "https://www.un.org/en/observances/disarmament-non-proliferation-awareness-day"),
    "03-15": .init(organization: "United Nations", url: "https://www.un.org/en/observances/anti-islamophobia-day"),
    "03-24": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-tb-day"),
    "03-25": .init(organization: "United Nations", url: "https://www.un.org/en/observances/transatlantic-slave-trade"),
    "03-26": .init(organization: "The Anita Kaufmann Foundation", url: "https://purpledayeveryday.org/"),
    "04-02": .init(organization: "United Nations", url: "https://www.un.org/en/observances/autism-day"),
    "04-04": .init(organization: "United Nations", url: "https://www.un.org/en/observances/mine-awareness-day"),
    "04-07": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-health-day"),
    "04-11": .init(organization: "Parkinson's Europe", url: "https://parkinsonseurope.org/campaigns/world-parkinsons-day/"),
    "04-17": .init(organization: "World Federation of Hemophilia", url: "https://wfh.org/world-hemophilia-day/"),
    "04-25": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-malaria-day"),
    "04-29": .init(organization: "United Nations", url: "https://www.un.org/en/observances/earthquake-victims-day"),
    "05-08": .init(organization: "United Nations", url: "https://www.un.org/en/observances/second-world-war-remembrance-days"),
    "05-28": .init(organization: "Menstrual Hygiene Day", url: "https://www.menstrualhygieneday.org/"),
    "06-04": .init(organization: "United Nations", url: "https://www.un.org/en/observances/child-victim-day"),
    "06-12": .init(organization: "International Labour Organization", url: "https://www.ilo.org/topics-and-sectors/child-labour/world-day-against-child-labour"),
    "06-15": .init(organization: "United Nations", url: "https://social.desa.un.org/issues/ageing/world-elder-abuse-awareness-day"),
    "06-18": .init(organization: "United Nations", url: "https://www.un.org/en/observances/countering-hate-speech"),
    "06-19": .init(organization: "United Nations", url: "https://www.un.org/en/observances/end-sexual-violence-in-conflict-day/"),
    "06-20": .init(organization: "United Nations", url: "https://www.un.org/en/observances/refugee-day"),
    "06-26": .init(organization: "United Nations", url: "https://www.un.org/en/observances/end-drug-abuse-day"),
    "07-28": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-hepatitis-day"),
    "08-02": .init(organization: "Council of Europe", url: "https://www.coe.int/en/web/roma-genocide/2-august-roma-genocide-remembrance-day"),
    "08-21": .init(organization: "United Nations", url: "https://www.un.org/en/observances/terrorism-victims-day"),
    "08-22": .init(organization: "United Nations", url: "https://www.un.org/en/observances/religious-based-violence-victims-day"),
    "08-23": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/slave-trade-remembrance"),
    "08-29": .init(organization: "United Nations", url: "https://www.un.org/en/observances/end-nuclear-tests-day"),
    "08-30": .init(organization: "United Nations", url: "https://www.un.org/en/observances/victims-enforced-disappearance"),
    "09-09": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/protect-education-attack"),
    "09-10": .init(organization: "World Health Organization / IASP", url: "https://www.who.int/campaigns/world-suicide-prevention-day"),
    "09-11": .init(organization: "National September 11 Memorial & Museum", url: "https://www.911memorial.org/plan-your-own-911-anniversary-observance"),
    "09-17": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-patient-safety-day"),
    "10-10": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-mental-health-day"),
    "10-18": .init(organization: "International Menopause Society", url: "https://www.imsociety.org/education/world-menopause-day-2025/"),
    "10-20": .init(organization: "International Osteoporosis Foundation", url: "https://www.worldosteoporosisday.org/get-involved"),
    "10-02": .init(organization: "United Nations", url: "https://www.un.org/en/observances/non-violence-day"),
    "11-12": .init(organization: "World Health Organization", url: "https://www.who.int/health-topics/pneumonia"),
    "11-14": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-diabetes-day"),
    "11-15": .init(organization: "United Nations", url: "https://www.un.org/en/observances/international-day-prevention-and-fight-against-all-forms-transnational-organized-crime"),
    "11-18": .init(organization: "United Nations", url: "https://www.un.org/en/observances/child-sexual-exploitation-prevention-and-healing-day"),
    "11-25": .init(organization: "United Nations", url: "https://www.un.org/en/observances/ending-violence-against-women-day"),
    "11-30": .init(organization: "Organisation for the Prohibition of Chemical Weapons", url: "https://www.opcw.org/remembrance"),
    "12-02": .init(organization: "United Nations", url: "https://www.un.org/en/observances/slavery-abolition-day"),
    "12-10": .init(organization: "UNESCO", url: "https://www.unesco.org/en/days/human-rights"),
    "12-12": .init(organization: "United Nations", url: "https://www.un.org/en/observances/universal-health-coverage-day")
]

private let culturalIDs: Set<String> = [
    "03-26", "04-11", "04-17", "05-28", "08-02", "09-10", "09-11",
    "10-18", "10-20", "11-12"
]

private let remembranceIDs: Set<String> = [
    "01-27", "03-25", "04-29", "05-08", "06-04", "08-02", "08-21",
    "08-22", "08-23", "08-29", "08-30", "09-09", "09-11", "11-18",
    "11-25", "11-30", "12-02"
]

private let healthIDs: Set<String> = [
    "03-24", "03-26", "04-02", "04-07", "04-11", "04-17", "04-25",
    "05-28", "07-28", "09-10", "09-17", "10-10", "10-18", "10-20",
    "11-12", "11-14", "12-12"
]

private let civilSocietyIDs: Set<String> = [
    "02-06", "02-12", "03-01", "03-05", "03-15", "04-04", "06-12",
    "06-15", "06-18", "06-19", "06-20", "06-26", "11-15", "12-10"
]

private let standardOfficialIDs: Set<String> = ["10-02"]

private let targetIDs = Set(copy.map(\.id))
private let expectedIDs = remembranceIDs.union(healthIDs).union(civilSocietyIDs).union(standardOfficialIDs).union(["11-17"])
guard copy.count == 50, targetIDs.count == copy.count, targetIDs == expectedIDs else {
    fatalError("Safety batch must contain exactly the 50 reviewed records")
}
guard Set(sources.keys) == targetIDs.subtracting(["11-17"]) else {
    fatalError("Every non-editorial record must have one reviewed primary source")
}

private let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
private let decoder = JSONDecoder()

private func loadLocalized(_ language: String) throws -> [LocalizedDay] {
    let url = root.appendingPathComponent("WhaDayNative/Data/\(language).json")
    return try decoder.decode([LocalizedDay].self, from: Data(contentsOf: url))
}

private func quote(_ value: String) -> String {
    String(data: try! JSONEncoder().encode(value), encoding: .utf8)!
}

private func render(_ days: [LocalizedDay]) -> String {
    let objects = days.map { day in
        """
          {
            "id": \(quote(day.id)),
            "month": \(day.month),
            "day": \(day.day),
            "title": \(quote(day.title)),
            "description": \(quote(day.description)),
            "emoji": \(quote(day.emoji)),
            "category": \(quote(day.category)),
            "sharingHook": \(quote(day.sharingHook))
          }
        """
    }
    return "[\n" + objects.joined(separator: ",\n") + "\n]\n"
}

private func curateLocalized(_ language: String) throws {
    var days = try loadLocalized(language)
    let existingIDs = Set(days.map(\.id))
    guard targetIDs.isSubset(of: existingIDs), days.count == 366 else {
        fatalError("\(language) corpus is missing reviewed records or is not a leap-year corpus")
    }

    let byID = Dictionary(uniqueKeysWithValues: copy.map { ($0.id, $0) })
    for index in days.indices {
        guard let patch = byID[days[index].id] else { continue }
        days[index].description = language == "tr" ? patch.trDescription : patch.enDescription
        days[index].sharingHook = language == "tr" ? patch.trHook : patch.enHook
        if days[index].id == "11-17" {
            let expected = language == "tr" ? "Dünya Prematüre Günü" : "World Prematurity Day"
            let replacement = language == "tr" ? "İlk Mesajı Atma Günü" : "Text First Day"
            guard days[index].title == expected || days[index].title == replacement else {
                fatalError("Refusing to replace unexpected 11-17 title: \(days[index].title)")
            }
            days[index].title = replacement
            days[index].emoji = "💬"
            days[index].category = "social"
        }
    }

    let url = root.appendingPathComponent("WhaDayNative/Data/\(language).json")
    try render(days).write(to: url, atomically: true, encoding: .utf8)
}

private func curateMetadata() throws {
    let url = root.appendingPathComponent("WhaDayNative/Data/metadata.json")
    guard var records = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [[String: Any]] else {
        fatalError("metadata.json is not an array of objects")
    }
    guard records.count == 366, targetIDs.isSubset(of: Set(records.compactMap { $0["id"] as? String })) else {
        fatalError("metadata corpus is missing reviewed records or is not a leap-year corpus")
    }

    var updated = 0
    for index in records.indices {
        guard let id = records[index]["id"] as? String, targetIDs.contains(id) else { continue }
        records[index]["reviewState"] = "curated"

        if id == "11-17" {
            records[index]["authority"] = "editorial"
            records[index]["category"] = "relationships"
            records[index]["sensitivity"] = "standard"
            records[index]["shareability"] = 5
            records[index]["audience"] = ["friend"]
            records[index]["scope"] = "whaday-editorial"
            records[index]["symbol"] = "💬"
            records[index].removeValue(forKey: "source")
        } else if standardOfficialIDs.contains(id) {
            records[index]["authority"] = "official"
            records[index]["category"] = "civil-society"
            records[index]["sensitivity"] = "standard"
            records[index]["shareability"] = 4
            records[index]["audience"] = ["community", "friend"]
            records[index]["scope"] = "international"
            guard let source = sources[id] else { fatalError("Missing source for \(id)") }
            records[index]["source"] = [
                "organization": source.organization,
                "url": source.url,
                "checkedAt": "2026-08-14"
            ]
        } else {
            records[index]["authority"] = culturalIDs.contains(id) ? "cultural" : "official"
            records[index]["category"] = remembranceIDs.contains(id)
                ? "remembrance"
                : (healthIDs.contains(id) ? "health-and-awareness" : "civil-society")
            records[index]["sensitivity"] = remembranceIDs.contains(id) ? "remembrance" : "considerate"
            records[index]["shareability"] = remembranceIDs.contains(id) ? 1 : 2
            records[index]["audience"] = ["careful-sharing"]
            records[index]["scope"] = culturalIDs.contains(id) ? "global-cultural" : "international"
            if id == "06-26" || id == "11-15" { records[index]["symbol"] = "🛡️" }

            guard let source = sources[id] else { fatalError("Missing source for \(id)") }
            records[index]["source"] = [
                "organization": source.organization,
                "url": source.url,
                "checkedAt": "2026-08-14"
            ]
        }
        updated += 1
    }
    guard updated == targetIDs.count else { fatalError("Expected 50 updates, wrote \(updated)") }

    let output = try JSONSerialization.data(
        withJSONObject: records,
        options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    )
    try output.write(to: url, options: .atomic)
}

try curateLocalized("tr")
try curateLocalized("en")
try curateMetadata()
print("Curated 50 safety-sensitive records across Turkish, English and metadata corpora")
