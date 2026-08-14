#!/usr/bin/env swift

import Foundation

// Editorial review for the remaining records that already had verified
// institutional provenance. Source verification and copy review remain separate.

private struct LocalizedDay: Codable {
    let id: String
    let month: Int
    let day: Int
    let title: String
    var description: String
    let emoji: String
    let category: String
    var sharingHook: String
}

private struct CopyPatch {
    let id: String
    let trDescription: String
    let trHook: String
    let enDescription: String
    let enHook: String
}

private let copy: [CopyPatch] = [
    .init(id: "01-04", trDescription: "Braille, dokunarak okunup yazılabilen bir alfabe sistemidir; bilgiye, eğitime ve bağımsız yaşama erişimin önemli araçlarından biridir.", trHook: "Erişilebilir bilginin herkes için olduğunu hatırlat", enDescription: "Braille is a tactile reading and writing system and an important tool for access to information, education and independent living.", enHook: "Share the reminder that information should be accessible"),
    .init(id: "01-14", trDescription: "Mantık, yalnızca semboller değil; iddiaları sınamak, çelişkileri fark etmek ve daha berrak düşünmek için ortak bir araçtır.", trHook: "Her şeyi sorgulayan arkadaşına gönder", enDescription: "Logic is more than symbols; it is a shared tool for testing claims, spotting contradictions and thinking more clearly.", enHook: "Send to the friend who questions everything"),
    .init(id: "01-24", trDescription: "Eğitim bir ayrıcalık değil, insan hakkıdır; öğrenme fırsatına eşit erişim bireylerin ve toplumların geleceğini değiştirir.", trHook: "Hayatına dokunan bir öğretmene ya da öğrenciye gönder", enDescription: "Education is a human right, not a privilege; equal access to learning can change the future of people and communities.", enHook: "Send to a teacher or learner who changed your life"),
    .init(id: "02-11", trDescription: "Bilimde kadınların ve kız çocuklarının eşit yer alması, daha geniş soruların sorulmasını ve daha güçlü çözümler üretilmesini sağlar.", trHook: "Bilime meraklı bir kıza ya da kadına gönder", enDescription: "Equal participation for women and girls in science broadens the questions we ask and strengthens the solutions we create.", enHook: "Send to a woman or girl who loves science"),
    .init(id: "02-13", trDescription: "Radyo, bir asrı aşan tarihinde yerel dilleri, müziği, haberi ve uzak toplulukları aynı frekansta buluşturmayı sürdürüyor.", trHook: "Sesini ve programını özlediğin kişiye gönder", enDescription: "Across more than a century, radio has kept bringing local languages, music, news and distant communities onto the same frequency.", enHook: "Send to someone whose voice or show you miss"),
    .init(id: "02-17", trDescription: "Turizmin krizlere karşı dayanıklı olması, yalnızca seyahati değil; geçimi turizme bağlı toplulukları ve yerel kültürü de korur.", trHook: "Birlikte yeni bir yer keşfedeceğine gönder", enDescription: "Resilient tourism protects more than travel; it supports communities whose livelihoods and local cultures depend on it.", enHook: "Send to someone you want to explore somewhere new with"),
    .init(id: "02-20", trDescription: "Sosyal adalet; haklara, fırsatlara ve güvenli çalışma koşullarına erişimin kim olduğuna göre değişmemesini gerektirir.", trHook: "Daha adil bir dünya isteyen biriyle paylaş", enDescription: "Social justice means access to rights, opportunity and safe working conditions should not depend on who you are.", enHook: "Share with someone who wants a fairer world"),
    .init(id: "02-21", trDescription: "Anadil; yalnızca iletişim değil, hafıza, aidiyet ve dünyayı görme biçimidir. Dil çeşitliliği insanlığın ortak mirasıdır.", trHook: "Kelimelerini sevdiğin birine gönder", enDescription: "A mother language carries more than communication; it holds memory, belonging and a way of seeing the world.", enHook: "Send to someone whose words you love"),
    .init(id: "03-22", trDescription: "Temiz ve güvenli suya erişim bir insan hakkıdır; su kaynaklarını korumak sağlık, doğa ve gelecek için ortak sorumluluktur.", trHook: "Suyu ve doğayı önemseyen biriyle paylaş", enDescription: "Access to clean, safe water is a human right; protecting water is a shared responsibility for health, nature and the future.", enHook: "Share with someone who cares about water and nature"),
    .init(id: "04-22", trDescription: "Dünya Günü, iklimi ve biyolojik çeşitliliği korumanın tek günlük bir jest değil, gündelik seçimlerle büyüyen ortak bir sorumluluk olduğunu hatırlatır.", trHook: "Gezegeni birlikte koruyacağına gönder", enDescription: "Earth Day reminds us that protecting climate and biodiversity is not a one-day gesture but a shared, everyday responsibility.", enHook: "Send to someone you want to protect the planet with"),
    .init(id: "04-23", trDescription: "Kitaplar başka hayatlara açılan kapılar; telif hakkı ise o kapıları kuran yazar ve üreticilerin emeğini koruyan çerçevedir.", trHook: "Sana mutlaka bir kitap önerecek kişiye gönder", enDescription: "Books open doors into other lives, while copyright protects the work of the writers and creators who build those doors.", enHook: "Send to someone who always has a book recommendation"),
    .init(id: "05-03", trDescription: "Özgür ve bağımsız gazetecilik, iktidarı sorgulamak ve toplumun doğrulanmış bilgiye ulaşması için temel bir güvencedir.", trHook: "Bağımsız haberciliğin değerini özenle paylaş", enDescription: "Free and independent journalism is essential for questioning power and helping the public reach verified information.", enHook: "Share the value of independent journalism with care"),
    .init(id: "06-05", trDescription: "Temiz hava, sağlıklı ekosistemler ve yaşanabilir kentler birbirinden ayrı değil; çevreyi korumak yaşamı korumaktır.", trHook: "Doğaya iyi gelecek bir adımı birlikte atacağına gönder", enDescription: "Clean air, healthy ecosystems and livable cities are connected; protecting the environment means protecting life.", enHook: "Send to someone you can take one greener step with"),
    .init(id: "06-08", trDescription: "Okyanuslar iklimi düzenler, sayısız canlıya yuva olur ve yaşamın devamı için gereken döngülerin merkezinde yer alır.", trHook: "Deniz özlemi çektiğin kişiye gönder", enDescription: "Oceans regulate climate, shelter extraordinary life and sit at the heart of cycles that sustain the planet.", enHook: "Send to someone you miss the sea with"),
    .init(id: "06-14", trDescription: "Gönüllü ve düzenli kan bağışı, acil durumlar ve sürekli tedaviler için güvenli kan stoklarının sürdürülebilmesini sağlar.", trHook: "Uygunluk bilgisini resmi kan merkezinden kontrol ederek paylaş", enDescription: "Voluntary, regular blood donation helps maintain safe supplies for emergencies and ongoing treatment.", enHook: "Share with care and direct eligibility questions to an official blood service"),
    .init(id: "06-17", trDescription: "Sağlıklı toprağı korumak ve bozulan arazileri onarmak; gıda güvenliği, biyolojik çeşitlilik ve kuraklığa dayanıklılık için önemlidir.", trHook: "Toprağa ve geleceğe değer veren biriyle paylaş", enDescription: "Protecting healthy soil and restoring degraded land support food security, biodiversity and resilience to drought.", enHook: "Share with someone who cares about land and the future"),
    .init(id: "06-21", trDescription: "Yoga; hareket, nefes ve dikkati bir araya getiren köklü bir uygulama. Bugün matı sermek için takvimden küçük bir dürtü var.", trHook: "Birlikte esneyeceğin kişiye gönder", enDescription: "Yoga is a longstanding practice that brings movement, breath and attention together. Consider this a small nudge to unroll the mat.", enHook: "Send to someone you would stretch with"),
    .init(id: "06-23", trDescription: "Dul kadınlar birçok yerde hak kaybı, ekonomik güvensizlik ve dışlanmayla karşılaşıyor; görünürlük, haklara erişimle anlam kazanır.", trHook: "Hak ve onuru merkeze alarak paylaş", enDescription: "Widows in many places face lost rights, economic insecurity and exclusion; visibility matters when it leads to access and dignity.", enHook: "Share with rights and dignity at the center"),
    .init(id: "07-15", trDescription: "Gençlerin becerilerine yatırım yapmak, yalnızca işe hazırlık değil; kendi geleceklerini kurabilmeleri için alan ve güven yaratmaktır.", trHook: "Yeteneklerine güvendiğin genç birine gönder", enDescription: "Investing in young people's skills is more than job preparation; it creates room and confidence to shape their own futures.", enHook: "Send to a young person whose skills you believe in"),
    .init(id: "08-09", trDescription: "Yerli halkların haklarını, dillerini ve bilgisini görünür kılmak; onlar adına konuşmak değil, kendi seslerine alan açmakla başlar.", trHook: "Yerli halkların kendi seslerini merkeze alarak paylaş", enDescription: "Supporting Indigenous rights, languages and knowledge begins by making room for Indigenous voices, not speaking over them.", enHook: "Share by centering Indigenous voices"),
    .init(id: "08-12", trDescription: "Gençler geleceğin yalnızca izleyicisi değil; bugünün kararlarında söz, kaynak ve gerçek katılım hakkına sahip ortaklarıdır.", trHook: "Fikrini önemsediğin genç birine gönder", enDescription: "Young people are not merely spectators of the future; they deserve voice, resources and real participation in today's decisions.", enHook: "Send to a young person whose ideas matter to you"),
    .init(id: "08-19", trDescription: "İnsani yardım çalışanları krizlerde hayat kurtarırken büyük riskler üstleniyor; sivillerin ve yardım ekiplerinin korunması vazgeçilmezdir.", trHook: "Sivilleri ve yardım çalışanlarını gözeterek paylaş", enDescription: "Humanitarian workers take serious risks to save lives in crises; protecting civilians and aid teams is essential.", enHook: "Share with civilians and aid workers in mind"),
    .init(id: "09-12", trDescription: "Güney-Güney iş birliği, benzer deneyimlere sahip ülkelerin bilgi, teknoloji ve çözümleri eşit ortaklıkla paylaşmasını güçlendirir.", trHook: "İş birliğinin sınırları aşan gücünü paylaş", enDescription: "South-South cooperation helps countries with shared experience exchange knowledge, technology and solutions as equal partners.", enHook: "Share the power of cooperation across borders"),
    .init(id: "09-21", trDescription: "Barış yalnızca çatışmanın yokluğu değil; adalet, insan hakları, diyalog ve güvenli bir yaşam için her gün emek vermektir.", trHook: "Barışa inanan birine gönder", enDescription: "Peace is more than the absence of conflict; it is daily work for justice, human rights, dialogue and safety.", enHook: "Send to someone who believes in peace"),
    .init(id: "10-11", trDescription: "Kız çocuklarının güvenliğe, eğitime ve kendi gelecekleri hakkında karar verme hakkına eşit erişimi temel bir insan hakkıdır.", trHook: "Kız çocuklarının haklarını özenle görünür kıl", enDescription: "Girls have an equal human right to safety, education and a say in decisions about their own futures.", enHook: "Share girls' rights with care"),
    .init(id: "10-15", trDescription: "Kırsal kadınlar gıda üretimi ve topluluk yaşamının merkezinde yer alırken toprağa, finansmana ve kararlara erişimde engellerle karşılaşabiliyor.", trHook: "Kırsal kadınların emeğini ve haklarını gözeterek paylaş", enDescription: "Rural women are central to food systems and community life, yet often face barriers to land, finance and decision-making.", enHook: "Share with rural women's work and rights in focus"),
    .init(id: "10-16", trDescription: "Gıda yalnızca kutlanacak bir lezzet değil, haktır; açlıkla mücadele etmek, israfı azaltmak ve sürdürülebilir üretimi desteklemek ortak sorumluluk.", trHook: "Gıda hakkını ve israfı azaltmayı özenle paylaş", enDescription: "Food is not only something to enjoy; it is a right. Ending hunger, reducing waste and supporting sustainable production are shared responsibilities.", enHook: "Share with the right to food and less waste in focus"),
    .init(id: "10-24", trDescription: "Birleşmiş Milletler Günü, ülkelerin barış, insan hakları ve ortak sorunlar için birlikte çalışma sözünü hatırlatır.", trHook: "Küresel iş birliğine inanan biriyle paylaş", enDescription: "United Nations Day recalls the promise that countries can work together for peace, human rights and shared challenges.", enHook: "Share with someone who believes in global cooperation"),
    .init(id: "12-01", trDescription: "HIV hakkında doğru bilgi, teste ve tedaviye erişim kadar damgalama ve ayrımcılıkla mücadele de hayat kurtarır.", trHook: "Doğru bilgiyle, damgalamadan paylaş", enDescription: "Accurate HIV information, access to testing and treatment, and fighting stigma all save lives.", enHook: "Share accurate information without stigma"),
    .init(id: "12-03", trDescription: "Erişilebilirlik bir iyilik değil, haktır. Engeller çoğu zaman bireylerde değil, onları dışarıda bırakan sistemlerdedir.", trHook: "Engelli bireylerin sesini merkeze alarak paylaş", enDescription: "Accessibility is a right, not a favour. Barriers often lie in systems that exclude people, not in individuals.", enHook: "Share by centering disabled people's voices")
]

private let considerateIDs: Set<String> = [
    "01-04", "05-03", "06-14", "06-23", "08-09", "08-19", "10-11",
    "10-15", "10-16", "12-01", "12-03"
]
private let natureIDs: Set<String> = ["03-22", "04-22", "06-05", "06-08", "06-17"]
private let cultureIDs: Set<String> = ["02-13", "02-21", "04-23"]
private let scienceIDs: Set<String> = ["01-14"]
private let healthIDs: Set<String> = ["06-14", "12-01"]
private let sportIDs: Set<String> = ["06-21"]
private let relationshipIDs: Set<String> = ["01-24", "07-15", "08-12"]
private let targetIDs = Set(copy.map(\.id))
guard copy.count == 30, targetIDs.count == copy.count else {
    fatalError("Expected 30 unique sourced records")
}

private let symbols: [String: String] = [
    "01-04": "⠿", "01-14": "💡", "01-24": "📚", "02-11": "👩‍🔬",
    "02-13": "📻", "02-17": "🧭", "02-20": "🤝", "02-21": "🗣️",
    "03-22": "💧", "04-22": "🌍", "04-23": "📚", "05-03": "📰",
    "06-05": "🌿", "06-08": "🌊", "06-14": "🩸", "06-17": "🌱",
    "06-21": "🧘", "06-23": "🤝", "07-15": "🛠️", "08-09": "🌎",
    "08-12": "✨", "08-19": "🤝", "09-12": "🤝", "09-21": "☮️",
    "10-11": "✨", "10-15": "🌾", "10-16": "🍽️", "10-24": "🌐",
    "12-01": "🎗️", "12-03": "♿️"
]

private let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

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
    let url = root.appendingPathComponent("WhaDayNative/Data/\(language).json")
    var days = try JSONDecoder().decode([LocalizedDay].self, from: Data(contentsOf: url))
    let byID = Dictionary(uniqueKeysWithValues: copy.map { ($0.id, $0) })
    guard days.count == 366, targetIDs.isSubset(of: Set(days.map(\.id))) else {
        fatalError("\(language) catalog is missing sourced records")
    }
    for index in days.indices {
        guard let patch = byID[days[index].id] else { continue }
        days[index].description = language == "tr" ? patch.trDescription : patch.enDescription
        days[index].sharingHook = language == "tr" ? patch.trHook : patch.enHook
    }
    try render(days).write(to: url, atomically: true, encoding: .utf8)
}

private func category(for id: String) -> String {
    if natureIDs.contains(id) { return "animals-and-nature" }
    if cultureIDs.contains(id) { return "culture-and-arts" }
    if scienceIDs.contains(id) { return "science-and-curiosity" }
    if healthIDs.contains(id) { return "health-and-awareness" }
    if sportIDs.contains(id) { return "sport-and-movement" }
    if relationshipIDs.contains(id) { return "relationships" }
    return "civil-society"
}

private func curateMetadata() throws {
    let url = root.appendingPathComponent("WhaDayNative/Data/metadata.json")
    guard var records = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [[String: Any]] else {
        fatalError("metadata.json is not an array")
    }
    var updated = 0
    for index in records.indices {
        guard let id = records[index]["id"] as? String, targetIDs.contains(id) else { continue }
        guard records[index]["authority"] as? String == "official",
              records[index]["source"] is [String: Any] else {
            fatalError("Refusing to curate sourced record without official provenance: \(id)")
        }
        records[index]["reviewState"] = "curated"
        records[index]["category"] = category(for: id)
        records[index]["sensitivity"] = considerateIDs.contains(id) ? "considerate" : "standard"
        records[index]["shareability"] = considerateIDs.contains(id) ? 2 : (relationshipIDs.contains(id) || id == "04-23" ? 5 : 4)
        records[index]["audience"] = considerateIDs.contains(id)
            ? ["careful-sharing"]
            : (relationshipIDs.contains(id) ? ["friend", "community"] : ["community"])
        records[index]["symbol"] = symbols[id]!
        updated += 1
    }
    guard updated == 30 else { fatalError("Expected 30 metadata updates, wrote \(updated)") }
    let output = try JSONSerialization.data(
        withJSONObject: records,
        options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    )
    try output.write(to: url, options: .atomic)
}

try curateLocalized("tr")
try curateLocalized("en")
try curateMetadata()
print("Curated 30 sourced institutional records")
