#!/usr/bin/env swift

import Foundation

// Human review for the final culture-specific, national and faith dates.

private struct LocalizedDay: Codable {
    let id: String
    let month: Int
    let day: Int
    var title: String
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

private struct SourcePatch {
    let organization: String
    let url: String
}

private let copy: [CopyPatch] = [
    .init(id: "01-01", trDescription: "Yeni yıl, farklı takvim ve geleneklerde farklı tarihlerde başlasa da 1 Ocak dünyanın büyük bölümünde yeni bir sayfa açmanın ortak simgesidir.", trHook: "Bu yılın ilk güzel haberini paylaşmak istediğin kişiye gönder", enDescription: "New years begin on different dates across calendars and traditions, but 1 January has become a widely shared symbol of turning a new page.", enHook: "Send to someone you want to share this year's first good news with"),
    .init(id: "01-05", trDescription: "Onikinci Gece, Batı Hristiyan geleneklerinde Noel döneminin sonunu ve Epifani arifesini işaretler; kutlama biçimleri ülkeye göre değişir.", trHook: "Yalnız ilgili gelenek bağlamında paylaş", enDescription: "Twelfth Night marks the close of the Christmas season and the eve of Epiphany in Western Christian traditions, with customs varying by country.", enHook: "Share only in the context of the relevant tradition"),
    .init(id: "01-06", trDescription: "Epifani, Batı Hristiyanlığında Müneccimlerin İsa'yı ziyaretini; birçok Doğu geleneğinde ise İsa'nın vaftizini öne çıkaran dinî bayramdır.", trHook: "İnanç ve gelenek bağlamına saygıyla paylaş", enDescription: "Epiphany emphasizes the Magi's visit to Jesus in Western Christianity and Jesus's baptism in many Eastern traditions.", enHook: "Share respectfully within its faith and tradition context"),
    .init(id: "01-07", trDescription: "Jülyen takvimini izleyen bazı Ortodoks kiliseleri Noel'i 7 Ocak'ta kutlar; bütün Ortodoks topluluklar aynı tarihi kullanmaz.", trHook: "Kutlayan birine kendi geleneğine saygıyla gönder", enDescription: "Some Orthodox churches following the Julian calendar celebrate Christmas on 7 January; not every Orthodox community uses the same date.", enHook: "Send respectfully to someone who celebrates in this tradition"),
    .init(id: "01-13", trDescription: "Eski Yılbaşı Gecesi, Jülyen takvimi ile Gregoryen takvimi arasındaki fark nedeniyle bazı Doğu Avrupa ve Balkan topluluklarında 13 Ocak gecesi kutlanır.", trHook: "Yeni yılı ikinci kez karşılayacak kişiye gönder", enDescription: "Old New Year's Eve is celebrated on the night of 13 January in some Eastern European and Balkan communities because of the difference between Julian and Gregorian calendars.", enHook: "Send to someone ready to welcome the new year twice"),
    .init(id: "01-19", trDescription: "Jülyen takvimini izleyen bazı Ortodoks geleneklerinde 19 Ocak, İsa'nın vaftizini anan Teofani bayramıdır; su kutsama törenleriyle ilişkilidir.", trHook: "Yalnız ilgili Ortodoks geleneği içinde paylaş", enDescription: "In some Orthodox traditions following the Julian calendar, 19 January is Theophany, commemorating Jesus's baptism and often marked by blessings of water.", enHook: "Share only within the relevant Orthodox tradition"),
    .init(id: "01-25", trDescription: "Burns Gecesi, İskoç şair Robert Burns'ün doğum gününde şiir, konuşmalar, müzik ve geleneksel bir akşam yemeğiyle kutlanır.", trHook: "Şiirle sofrayı aynı anda seven kişiye gönder", enDescription: "Burns Night celebrates Scottish poet Robert Burns on his birthday through poetry, speeches, music and a traditional supper.", enHook: "Send to someone who loves poetry and dinner in equal measure"),
    .init(id: "01-31", trDescription: "Katolik gelenekte Aziz Don Bosco'nun yortu günü; yaşamını gençlerin eğitimine ve desteğine adayan rahip ve eğitimciyi anar.", trHook: "Gençlere yol açan bir eğitimciye gönder", enDescription: "The Catholic feast of Saint John Bosco remembers a priest and educator who devoted his life to the education and support of young people.", enHook: "Send to an educator who opens paths for young people"),
    .init(id: "02-15", trDescription: "Parinirvana Günü, birçok Mahayana Budist geleneğinde Buda'nın ölümünü ve nihai nirvanaya erişmesini tefekkürle anar; tarih bazı topluluklarda değişebilir.", trHook: "Yalnız ilgili Budist gelenek bağlamında paylaş", enDescription: "Parinirvana Day is observed in many Mahayana Buddhist traditions through reflection on the Buddha's death and final nirvana; the date can vary by community.", enHook: "Share only within the relevant Buddhist tradition"),
    .init(id: "02-24", trDescription: "24 Şubat, Estonya'nın 1918'de bağımsızlığını ilan ettiği tarihtir; bayrak törenleri ve ülke çapındaki etkinliklerle kutlanır.", trHook: "Estonya'yla bağı olan birine gönder", enDescription: "24 February marks Estonia's 1918 declaration of independence and is observed with flag ceremonies and events across the country.", enHook: "Send to someone connected to Estonia"),
    .init(id: "02-26", trDescription: "Kuveyt Kurtuluş Günü, ülkenin 1991'de Irak işgalinden kurtuluşunu anan ulusal gündür; Bağımsızlık Günü'nün hemen ardından gelir.", trHook: "Kuveyt'le bağı olan biriyle tarihsel bağlamında paylaş", enDescription: "Kuwait Liberation Day marks the country's 1991 liberation from Iraqi occupation and follows immediately after National Day.", enHook: "Share with someone connected to Kuwait and with historical context"),
    .init(id: "03-17", trDescription: "Aziz Patrick Günü, İrlanda'nın koruyucu azizini anan dinî bir günden küresel ölçekte İrlanda kültürü ve diasporasını kutlayan bir güne dönüştü.", trHook: "Bugün yeşile bürünecek kişiye gönder", enDescription: "Saint Patrick's Day grew from a religious feast for Ireland's patron saint into a global celebration of Irish culture and diaspora.", enHook: "Send to someone who will find a way to wear green today"),
    .init(id: "03-19", trDescription: "Aziz Yusuf Günü, Katolik gelenekte Meryem'in eşi ve İsa'nın dünyevi babası kabul edilen Yusuf'u anar; yerel gelenekler büyük çeşitlilik gösterir.", trHook: "Yalnız ilgili inanç ve yerel gelenek bağlamında paylaş", enDescription: "Saint Joseph's Day honors Mary's husband and Jesus's earthly father in Catholic tradition, with customs that vary widely by place.", enHook: "Share only within its relevant faith and local context"),
    .init(id: "04-13", trDescription: "Songkran, Tayland yeni yılının başlangıcını suyla arınma, aile ziyaretleri ve bugün ünlü su kutlamalarıyla işaretler; festival genellikle birkaç gün sürer.", trHook: "Su savaşında yanında olmak isteyeceğin kişiye gönder", enDescription: "Songkran marks the Thai new year through cleansing with water, family visits and today's famous water celebrations, usually lasting several days.", enHook: "Send to someone you want on your side in a water fight"),
    .init(id: "05-09", trDescription: "9 Mayıs Zafer Günü, Rusya ve bazı eski Sovyet ülkelerinde Nazi Almanyası'nın yenilgisini ve İkinci Dünya Savaşı'nın ağır kayıplarını anar.", trHook: "Savaşın kayıplarını tarihsel bağlamıyla ve saygıyla an", enDescription: "Victory Day on 9 May commemorates Nazi Germany's defeat and the immense losses of the Second World War in Russia and some former Soviet countries.", enHook: "Remember wartime loss respectfully and with historical context"),
    .init(id: "07-01", trDescription: "Kanada Günü, 1 Temmuz 1867'de Kanada Konfederasyonu'nun kurulmasını işaretler; kutlamalar ülkenin sömürge ve Yerli halklar tarihine dair tartışmaları da taşır.", trHook: "Kanada'yla bağı olan biriyle bağlamını bilerek paylaş", enDescription: "Canada Day marks the formation of Canadian Confederation on 1 July 1867; observance also carries debate about colonial history and Indigenous peoples.", enHook: "Share with someone connected to Canada and aware of its context"),
    .init(id: "07-04", trDescription: "4 Temmuz, on üç koloninin 1776 Bağımsızlık Bildirgesi'ni kabul ettiği tarihi anan Amerika Birleşik Devletleri ulusal günüdür.", trHook: "ABD'yle bağı olan birine gönder", enDescription: "The Fourth of July is the United States national day, marking the thirteen colonies' adoption of the Declaration of Independence in 1776.", enHook: "Send to someone connected to the United States"),
    .init(id: "07-09", trDescription: "9 Temmuz, Arjantin Kongresi'nin 1816'da İspanya'dan bağımsızlığı ilan ettiği tarihi işaretleyen ulusal gündür.", trHook: "Arjantin'le bağı olan birine gönder", enDescription: "9 July is Argentina's national day, marking the 1816 declaration of independence from Spain by the Congress of Tucumán.", enHook: "Send to someone connected to Argentina"),
    .init(id: "07-13", trDescription: "Karadağ Devlet Günü, 1878'de bağımsızlığının uluslararası tanınmasını ve 1941'de işgale karşı başlayan ayaklanmayı aynı tarihte anar.", trHook: "Karadağ'la bağı olan biriyle tarihsel bağlamında paylaş", enDescription: "Montenegro Statehood Day marks both international recognition of independence in 1878 and the 1941 uprising against occupation.", enHook: "Share with someone connected to Montenegro and with historical context"),
    .init(id: "07-14", trDescription: "Fransa Ulusal Bayramı, 1789 Bastille Baskını ile 1790 Federasyon Bayramı'nın mirasını; törenler, buluşmalar ve havai fişeklerle taşır.", trHook: "Fransa'yla bağı olan ya da Paris'i özleyen kişiye gönder", enDescription: "France's national day carries the legacy of the 1789 storming of the Bastille and the 1790 Fête de la Fédération through ceremonies, gatherings and fireworks.", enHook: "Send to someone connected to France or missing Paris"),
    .init(id: "07-16", trDescription: "Karmel Dağı Meryem Ana Bayramı, Katolik gelenekte Karmelit tarikatının Meryem'e bağlılığını anan ve farklı ülkelerde yerel törenlerle yaşatılan gündür.", trHook: "Yalnız ilgili Katolik gelenek bağlamında paylaş", enDescription: "The feast of Our Lady of Mount Carmel reflects the Carmelite tradition's devotion to Mary and is observed through varied local customs.", enHook: "Share only within the relevant Catholic tradition"),
    .init(id: "07-19", trDescription: "19 Temmuz, Nikaragua'da Somoza yönetiminin 1979'da devrilmesini anan siyasi ve ulusal gündür; anlamı güncel siyasette farklı yorumlanır.", trHook: "Nikaragua'nın tarihsel ve siyasi bağlamını gözeterek paylaş", enDescription: "19 July marks the 1979 overthrow of the Somoza government in Nicaragua; its meaning is interpreted differently in current politics.", enHook: "Share with Nicaragua's historical and political context in mind"),
    .init(id: "07-21", trDescription: "Belçika Ulusal Günü, I. Léopold'un 21 Temmuz 1831'de anayasal kral olarak yemin etmesini işaretler.", trHook: "Belçika'yla bağı olan ya da waffle planı yapan kişiye gönder", enDescription: "Belgian National Day marks Leopold I taking the oath as constitutional monarch on 21 July 1831.", enHook: "Send to someone connected to Belgium or planning waffles"),
    .init(id: "07-23", trDescription: "Mısır Devrim Günü, Hür Subaylar hareketinin 23 Temmuz 1952'de monarşiyi deviren hareketini anan ulusal gündür.", trHook: "Mısır tarihine meraklı biriyle bağlamını bilerek paylaş", enDescription: "Egypt's Revolution Day marks the Free Officers movement of 23 July 1952 that overthrew the monarchy.", enHook: "Share with someone curious about Egyptian history and with context"),
    .init(id: "08-14", trDescription: "Pakistan Bağımsızlık Günü, ülkenin 1947'de Britanya yönetiminden ayrılarak kurulmasını işaretler.", trHook: "Pakistan'la bağı olan birine gönder", enDescription: "Pakistan Independence Day marks the country's creation and independence from British rule in 1947.", enHook: "Send to someone connected to Pakistan"),
    .init(id: "08-15", trDescription: "Meryem'in Göğe Alınışı, Katolik inancında Meryem'in yaşamının sonunda bedeni ve ruhuyla göğe alındığını kutlayan önemli bir bayramdır.", trHook: "Yalnız ilgili Katolik inanç bağlamında paylaş", enDescription: "The Assumption is a major Catholic feast celebrating the belief that Mary was taken body and soul into heaven at the end of her earthly life.", enHook: "Share only within the relevant Catholic faith context"),
    .init(id: "08-17", trDescription: "Endonezya Bağımsızlık Günü, Sukarno ve Mohammad Hatta'nın 17 Ağustos 1945'te bağımsızlığı ilan ettiği tarihi işaretler.", trHook: "Endonezya'yla bağı olan birine gönder", enDescription: "Indonesia Independence Day marks Sukarno and Mohammad Hatta's proclamation of independence on 17 August 1945.", enHook: "Send to someone connected to Indonesia"),
    .init(id: "08-24", trDescription: "Ukrayna Bağımsızlık Günü, parlamentonun 24 Ağustos 1991'de bağımsızlık ilanını kabul ettiği tarihi işaretler.", trHook: "Ukrayna'yla bağı olan birine dayanışmayla gönder", enDescription: "Ukraine Independence Day marks parliament's adoption of the declaration of independence on 24 August 1991.", enHook: "Send in solidarity to someone connected to Ukraine"),
    .init(id: "09-02", trDescription: "2 Eylül 1945'te Japonya'nın resmî teslim belgesi imzalandı ve İkinci Dünya Savaşı sona erdi; gün savaşın tüm kayıplarını tarihsel bağlamıyla anmak için ele alınmalı.", trHook: "Savaşın kayıplarını ve sona erişini saygıyla an", enDescription: "Japan's formal surrender was signed on 2 September 1945, ending the Second World War; the date should be approached with the war's full human loss in view.", enHook: "Remember the war's losses and its end with care"),
    .init(id: "10-12", trDescription: "İspanya Ulusal Günü, Amerika'yla tarihsel bağları da vurgular; sömürgecilik mirası nedeniyle kutlamanın anlamı farklı topluluklarda tartışmalıdır.", trHook: "İspanya ve sömürgecilik bağlamını gözeterek paylaş", enDescription: "Spain's national day also emphasizes historical ties with the Americas; its meaning is contested because of colonial legacy.", enHook: "Share with Spain's history and colonial context in mind"),
    .init(id: "11-22", trDescription: "Azize Cecilia Günü, müziğin koruyucu azizi kabul edilen Cecilia'yı anıyor; dünyanın farklı yerlerinde konser ve kilise müziği gelenekleriyle yaşatılıyor.", trHook: "Müziği hayatının dili yapan kişiye gönder", enDescription: "St Cecilia's Day honors the patron saint of music and is marked in different places through concerts and church-music traditions.", enHook: "Send to someone who has made music their language"),
    .init(id: "12-06", trDescription: "Aziz Nikolaus Günü, cömertliğiyle tanınan 4. yüzyıl piskoposunu anar; Avrupa'daki hediye gelenekleri Noel Baba figürünü de etkiledi.", trHook: "İyiliğini sessizce bırakan kişiye gönder", enDescription: "Saint Nicholas Day remembers a fourth-century bishop known for generosity; European gift traditions around him also shaped the figure of Santa Claus.", enHook: "Send to someone who leaves kindness quietly"),
    .init(id: "12-08", trDescription: "Günahsız Gebelik Bayramı, Katolik inancında Meryem'in kendi ana rahmine düştüğü andan itibaren ilk günahtan korunmuş olduğunu kutlar; İsa'nın doğumuyla karıştırılmamalıdır.", trHook: "Yalnız ilgili Katolik inanç bağlamında paylaş", enDescription: "The Immaculate Conception celebrates the Catholic belief that Mary was preserved from original sin from her own conception; it is not the conception of Jesus.", enHook: "Share only within the relevant Catholic faith context"),
    .init(id: "12-13", trDescription: "Azize Lucia Günü, özellikle İskandinav ülkelerinde kış karanlığında ışığı simgeleyen beyaz giysiler, mumlar ve şarkılarla kutlanır.", trHook: "Kışın ortasında ışık taşıyan kişiye gönder", enDescription: "Saint Lucy's Day is celebrated especially in Scandinavia with white clothing, candles and songs symbolizing light in winter darkness.", enHook: "Send to someone who carries light through the middle of winter"),
    .init(id: "12-16", trDescription: "Las Posadas, 16-24 Aralık arasında Meksika ve bazı Latin Amerika topluluklarında Meryem ile Yusuf'un konaklama arayışını canlandıran dokuz gecelik gelenektir.", trHook: "Yalnız ilgili kültürel ve dinî gelenek bağlamında paylaş", enDescription: "Las Posadas is a nine-night tradition from 16-24 December in Mexico and some Latin American communities, reenacting Mary and Joseph's search for lodging.", enHook: "Share only within the relevant cultural and religious tradition"),
    .init(id: "12-24", trDescription: "Noel Arifesi, birçok Hristiyan toplulukta İsa'nın doğum bayramından önce ibadet, aile buluşmaları ve yerel geleneklerle geçirilen gecedir.", trHook: "Bu geceyi kutlayan birine kendi geleneğine saygıyla gönder", enDescription: "Christmas Eve is observed in many Christian communities through worship, family gatherings and local customs before the feast of Jesus's birth.", enHook: "Send respectfully to someone celebrating in their own tradition"),
    .init(id: "12-25", trDescription: "Noel, Hristiyanlıkta İsa'nın doğumunu kutlayan bayramdır; dinî ibadetlerin yanında çok farklı aile ve kültür gelenekleri taşır.", trHook: "Noel'i kutlayan birine sıcak bir dilekle gönder", enDescription: "Christmas celebrates the birth of Jesus in Christianity and carries a wide range of family and cultural traditions alongside worship.", enHook: "Send a warm wish to someone celebrating Christmas"),
    .init(id: "12-26", trDescription: "Boxing Day, Birleşik Krallık ve bazı Commonwealth ülkelerinde Noel'in ertesi günü kutlanan resmî tatildir; yardım ve hizmet geleneği bugün alışveriş ve sporla da birleşir.", trHook: "Noel sonrası dinlenmeyi hak eden kişiye gönder", enDescription: "Boxing Day is a public holiday after Christmas in the UK and parts of the Commonwealth, where older traditions of giving now sit alongside shopping and sport.", enHook: "Send to someone who deserves a quiet day after Christmas")
]

private let sources: [String: SourcePatch] = [
    "01-25": .init(organization: "Scottish Poetry Library", url: "https://www.scottishpoetrylibrary.org.uk/poet/robert-burns/"),
    "02-24": .init(organization: "Republic of Estonia", url: "https://www.eesti.ee/"),
    "03-17": .init(organization: "Government of Ireland", url: "https://www.ireland.ie/en/stpatricks-day/"),
    "04-13": .init(organization: "Tourism Authority of Thailand", url: "https://www.tourismthailand.org/"),
    "05-09": .init(organization: "Imperial War Museums", url: "https://www.iwm.org.uk/history/what-you-need-to-know-about-ve-day"),
    "07-01": .init(organization: "Government of Canada", url: "https://www.canada.ca/en/canadian-heritage/campaigns/canada-day.html"),
    "07-04": .init(organization: "US National Archives", url: "https://www.archives.gov/founding-docs/declaration"),
    "07-09": .init(organization: "Government of Argentina", url: "https://www.argentina.gob.ar/"),
    "07-14": .init(organization: "Government of France", url: "https://www.elysee.fr/en/french-presidency/bastille-day-14-july"),
    "08-14": .init(organization: "Government of Pakistan", url: "https://pakistan.gov.pk/"),
    "08-17": .init(organization: "Government of Indonesia", url: "https://indonesia.go.id/"),
    "08-24": .init(organization: "Government of Ukraine", url: "https://www.kmu.gov.ua/en"),
    "09-02": .init(organization: "US National Archives", url: "https://www.archives.gov/milestone-documents/surrender-of-japan"),
    "12-16": .init(organization: "Smithsonian Institution", url: "https://americanhistory.si.edu/explore/stories/las-posadas"),
    "12-26": .init(organization: "Encyclopaedia Britannica", url: "https://www.britannica.com/topic/Boxing-Day")
]

private let targetIDs = Set(copy.map(\.id))
private let remembranceIDs: Set<String> = ["05-09", "09-02"]
private let considerateIDs: Set<String> = ["10-12"]
private let countryIDs: Set<String> = [
    "02-24", "02-26", "05-09", "07-01", "07-04", "07-09", "07-13",
    "07-14", "07-19", "07-21", "07-23", "08-14", "08-17", "08-24",
    "09-02", "10-12"
]
private let faithIDs = targetIDs.subtracting(countryIDs).subtracting(["01-01", "01-13", "01-25", "04-13", "12-26"])

guard copy.count == 38, targetIDs.count == copy.count else {
    fatalError("Expected 38 unique cultural records")
}

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
        fatalError("\(language) corpus is missing cultural records")
    }
    for index in days.indices {
        guard let patch = byID[days[index].id] else { continue }
        days[index].description = language == "tr" ? patch.trDescription : patch.enDescription
        days[index].sharingHook = language == "tr" ? patch.trHook : patch.enHook
        if days[index].id == "01-13" {
            days[index].title = language == "tr" ? "Eski Yılbaşı Gecesi" : "Old New Year's Eve"
        } else if days[index].id == "05-09" {
            days[index].title = language == "tr" ? "Zafer Günü (9 Mayıs Geleneği)" : "Victory Day (9 May Tradition)"
        } else if days[index].id == "09-02" {
            days[index].title = language == "tr" ? "İkinci Dünya Savaşı'nın Sona Erişini Anma" : "Remembering the End of World War II"
        }
    }
    try render(days).write(to: url, atomically: true, encoding: .utf8)
}

private func curateMetadata() throws {
    let url = root.appendingPathComponent("WhaDayNative/Data/metadata.json")
    guard var records = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [[String: Any]] else {
        fatalError("metadata.json is not an array")
    }
    var updated = 0
    for index in records.indices {
        guard let id = records[index]["id"] as? String, targetIDs.contains(id) else { continue }
        records[index]["reviewState"] = "curated"
        records[index]["authority"] = "cultural"
        records[index]["category"] = remembranceIDs.contains(id) ? "remembrance" : "celebrations"
        records[index]["sensitivity"] = remembranceIDs.contains(id) ? "remembrance" : (considerateIDs.contains(id) ? "considerate" : "standard")
        records[index]["shareability"] = remembranceIDs.contains(id) ? 1 : (considerateIDs.contains(id) ? 2 : (id == "01-01" ? 4 : 3))
        records[index]["audience"] = remembranceIDs.contains(id) || considerateIDs.contains(id) ? ["careful-sharing"] : ["observer", "community"]
        records[index]["scope"] = countryIDs.contains(id) || faithIDs.contains(id) ? "culture-specific" : "international"
        if let source = sources[id] {
            records[index]["source"] = ["organization": source.organization, "url": source.url, "checkedAt": "2026-08-14"]
        } else {
            records[index].removeValue(forKey: "source")
        }
        updated += 1
    }
    guard updated == 38 else { fatalError("Expected 38 metadata updates, wrote \(updated)") }
    let output = try JSONSerialization.data(withJSONObject: records, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    try output.write(to: url, options: .atomic)
}

try curateLocalized("tr")
try curateLocalized("en")
try curateMetadata()
print("Curated 38 culture-specific records")
