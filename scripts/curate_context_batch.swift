#!/usr/bin/env swift

import Foundation

// Human-reviewed copy and metadata for observances where health, identity,
// conflict, rights or historical context must outrank engagement mechanics.

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

private struct SourcePatch {
    let organization: String
    let url: String
}

private let copy: [CopyPatch] = [
    .init(id: "02-01", trDescription: "Dünya Başörtüsü Günü, başörtüsü takan kadınların seçimlerini ve deneyimlerini kendi seslerinden dinlemeye; onları tek bir hikâyeye indirgememeye çağırır.", trHook: "Başörtüsü takan kadınların kendi sesini öne çıkararak paylaş", enDescription: "World Hijab Day invites people to listen to women who wear hijab in their own voices, without reducing them to a single story.", enHook: "Share by centering the voices of women who wear hijab"),
    .init(id: "02-04", trDescription: "İnsan kardeşliği; inanç, kültür ve görüş farklılıklarını silmek değil, bu farklılıklarla eşitlik ve karşılıklı saygı içinde yaşayabilmektir.", trHook: "Farklılıklarla yan yana durabildiğin kişiye gönder", enDescription: "Human fraternity is not about erasing differences in belief, culture or opinion; it is about living with them in equality and mutual respect.", enHook: "Send to someone you can stand beside across differences"),
    .init(id: "02-19", trDescription: "19 Şubat 1945'te başlayan Iwo Jima Muharebesi, Pasifik Savaşı'nın en ağır çatışmalarından biriydi; bugün kayıplar savaşın insani bedeliyle birlikte anılıyor.", trHook: "Kayıpları ve savaşın bedelini saygıyla an", enDescription: "The Battle of Iwo Jima began on 19 February 1945 and became one of the Pacific War's fiercest battles; its losses are remembered alongside the human cost of war.", enHook: "Remember the losses and human cost of war with care"),
    .init(id: "02-23", trDescription: "Anavatanı Savunma Günü, Rusya ve bazı eski Sovyet ülkelerinde askerî hizmetle ilişkilendirilen, anlamı ülkeye ve döneme göre değişen bir anma ve tatil günüdür.", trHook: "Yalnızca ilgili kültürel bağlam içinde paylaş", enDescription: "Defender of the Fatherland Day is a military-linked commemoration and holiday in Russia and some former Soviet states whose meaning varies by country and period.", enHook: "Share only with its specific cultural context"),
    .init(id: "02-25", trDescription: "1986'daki Halk Gücü hareketi, Filipinler'de milyonların şiddetsiz protestolarla otoriter yönetime karşı çıkıp demokratik değişim talep ettiği dönüm noktasıdır.", trHook: "Demokratik katılımın gücüne inanan biriyle paylaş", enDescription: "The 1986 People Power movement marked the moment millions in the Philippines used nonviolent protest to oppose authoritarian rule and demand democratic change.", enHook: "Share with someone who believes in democratic participation"),
    .init(id: "03-12", trDescription: "Siber sansüre karşı durmak; internete erişimi, ifade özgürlüğünü ve gazetecilerin çevrimiçi baskı olmadan çalışabilmesini savunmaktır.", trHook: "Özgür ve açık interneti savunan birine gönder", enDescription: "Standing against cyber-censorship means defending internet access, freedom of expression and journalists' ability to work without online repression.", enHook: "Send to someone who defends a free and open internet"),
    .init(id: "03-31", trDescription: "Trans Görünürlük Günü, trans bireylerin yaşamlarını ve katkılarını kutlarken ayrımcılık, şiddet ve eşitsizlik deneyimlerini de görünür kılar.", trHook: "Trans bireylerin kendi seslerini özenle büyüt", enDescription: "Transgender Day of Visibility celebrates trans lives and contributions while drawing attention to discrimination, violence and inequality.", enHook: "Amplify trans voices with care"),
    .init(id: "04-08", trDescription: "Dünya Romanlar Günü, Roman dili ve kültürünü kutlarken Romanlara yönelik ırkçılık ve dışlanmaya karşı eşit hak talebini de görünür kılar.", trHook: "Romanların kendi sesini ve kültürünü merkeze alarak paylaş", enDescription: "International Romani Day celebrates Roma language and culture while highlighting the call for equal rights and an end to anti-Roma racism.", enHook: "Share by centering Roma voices and culture"),
    .init(id: "04-14", trDescription: "Chagas, tedavi edilmediğinde ciddi kalp ve sindirim sorunlarına yol açabilen paraziter bir hastalıktır; erken tanı ve bakıma erişim önemlidir.", trHook: "Chagas hakkında yalnızca güvenilir sağlık bilgisi paylaş", enDescription: "Chagas is a parasitic disease that can cause serious heart and digestive problems if untreated; early diagnosis and access to care matter.", enHook: "Share only reliable health information about Chagas"),
    .init(id: "04-28", trDescription: "Güvenli ve sağlıklı çalışma ortamı temel bir haktır; önlenebilir kazaları ve meslek hastalıklarını azaltmak işverenler ve kurumlar için sürekli sorumluluktur.", trHook: "Güvenli çalışma hakkını bağlamıyla paylaş", enDescription: "A safe and healthy working environment is a fundamental right; preventing occupational injury and disease is an ongoing responsibility for employers and institutions.", enHook: "Share the right to safe work with context"),
    .init(id: "05-01", trDescription: "1 Mayıs, işçilerin dayanışmasını ve insanca çalışma, adil ücret, örgütlenme ve güvenlik mücadelelerinin uzun tarihini görünür kılar.", trHook: "Emeğin ve dayanışmanın değerini paylaş", enDescription: "May Day highlights worker solidarity and the long history of struggles for decent work, fair pay, organizing and safety.", enHook: "Share the value of labour and solidarity"),
    .init(id: "05-23", trDescription: "Obstetrik fistül büyük ölçüde önlenebilir ve tedavi edilebilir; nitelikli doğum bakımına ve zamanında tedaviye erişim kadınların sağlığı ve onuru için kritiktir.", trHook: "Kadınların sağlığını ve onurunu gözeterek paylaş", enDescription: "Obstetric fistula is largely preventable and treatable; access to quality maternity care and timely treatment is critical to women's health and dignity.", enHook: "Share with women's health and dignity in focus"),
    .init(id: "05-31", trDescription: "Tütün kullanımı önlenebilir hastalık ve ölüm nedenlerinden biridir; dumansız yaşamı desteklemek doğru bilgiye, koruyucu politikalara ve yardıma erişim gerektirir.", trHook: "Tütün konusunda güvenilir sağlık bilgisiyle paylaş", enDescription: "Tobacco use is a preventable cause of disease and death; supporting tobacco-free lives requires accurate information, protective policy and access to help.", enHook: "Share reliable health information about tobacco"),
    .init(id: "06-02", trDescription: "2 Haziran, seks işçilerinin şiddet, damgalama ve ayrımcılığa karşı güvenlik, sağlık ve insan hakları taleplerini kendi sesleriyle duyurduğu bir gündür.", trHook: "Seks işçilerinin kendi seslerini ve güvenliğini merkeze al", enDescription: "2 June centers sex workers' own calls for safety, health and human rights in the face of violence, stigma and discrimination.", enHook: "Center sex workers' own voices and safety"),
    .init(id: "06-13", trDescription: "Albinizm kalıtsal bir genetik durumdur; yanlış inanışlar bazı yerlerde ayrımcılık ve şiddeti beslerken güneşten korunma ve göz sağlığına erişim önem taşır.", trHook: "Albinizmli bireylerin sesini doğru bilgiyle büyüt", enDescription: "Albinism is an inherited genetic condition; myths can fuel discrimination and violence, while access to sun protection and eye care matters.", enHook: "Amplify people with albinism using accurate information"),
    .init(id: "06-28", trDescription: "28 Haziran, Stonewall ayaklanmasının yıldönümünden doğan Onur hareketinin LGBTQ+ bireyler için görünürlük, eşitlik ve güvenlik talebini kutlar.", trHook: "Kendisi olma cesaretini kutladığın kişiye gönder", enDescription: "28 June marks the legacy of the Stonewall uprising and celebrates the Pride movement's call for LGBTQ+ visibility, equality and safety.", enHook: "Send to someone whose courage to be themselves you celebrate"),
    .init(id: "07-18", trDescription: "Nelson Mandela Günü, Mandela'nın adalet, uzlaşma ve insan onuru için verdiği mücadelenin gündelik toplumsal eylemlerle sürdürülmesini teşvik eder.", trHook: "İyiliği eyleme dönüştüren birine gönder", enDescription: "Nelson Mandela International Day encourages everyday community action in the spirit of Mandela's work for justice, reconciliation and human dignity.", enHook: "Send to someone who turns good intentions into action"),
    .init(id: "07-25", trDescription: "Boğulmalar çoğu zaman önlenebilir; yakın gözetim, güvenli bariyerler, yüzme ve kurtarma becerileri ile can yeleği kullanımı riski azaltabilir.", trHook: "Su güvenliği bilgisini sorumlulukla paylaş", enDescription: "Drowning is often preventable; close supervision, safe barriers, swimming and rescue skills, and lifejackets can reduce risk.", enHook: "Share water-safety information responsibly"),
    .init(id: "08-01", trDescription: "Dünya Emzirme Haftası 1-7 Ağustos'ta emzirme desteğine dikkat çeker; her ailenin koşulları farklıdır ve doğru destek yargısız, bilgili ve erişilebilir olmalıdır.", trHook: "Ailelerin farklı koşullarını gözeterek paylaş", enDescription: "World Breastfeeding Week, 1-7 August, highlights breastfeeding support; every family's circumstances differ, and good support should be informed, accessible and free of judgment.", enHook: "Share with different family circumstances in mind"),
    .init(id: "08-31", trDescription: "Afrika Kökenlilerin Uluslararası Günü, Afrika diasporasının katkılarını görünür kılarken kölelik mirası ve sistemik ırkçılığa karşı eşitlik talebini güçlendirir.", trHook: "Afrika kökenli insanların kendi seslerini merkeze al", enDescription: "The International Day for People of African Descent recognizes the African diaspora's contributions while strengthening calls for equality against slavery's legacy and systemic racism.", enHook: "Center the voices of people of African descent"),
    .init(id: "09-18", trDescription: "Eşit değerde işe eşit ücret, ekonomik bağımsızlık ve toplumsal cinsiyet eşitliği için temel bir haktır; ücret farkı kişisel tercihlerle açıklanamaz.", trHook: "Eşit emeğe eşit ücret talebini özenle paylaş", enDescription: "Equal pay for work of equal value is essential to economic independence and gender equality; the pay gap cannot be reduced to personal choices.", enHook: "Share the call for equal pay with care"),
    .init(id: "09-26", trDescription: "Nükleer silahlar ayrım gözetmeyen ve kuşaklar boyu sürebilen insani sonuçlar doğurur; tamamen ortadan kaldırılmaları kalıcı güvenliğin şartıdır.", trHook: "Nükleer silahsızlanma çağrısını bağlamıyla paylaş", enDescription: "Nuclear weapons cause indiscriminate humanitarian harm that can last for generations; their total elimination is essential to lasting security.", enHook: "Share the call for nuclear disarmament with context"),
    .init(id: "10-06", trDescription: "Serebral palsi hareket ve duruşu etkileyen, kişiden kişiye çok farklı yaşanan bir grup durumdur; erişilebilirlik ve bireyin kendi hedefleri merkezdedir.", trHook: "Serebral palsili bireylerin kendi deneyimini öne çıkar", enDescription: "Cerebral palsy is a group of conditions affecting movement and posture, experienced very differently from person to person; accessibility and individual goals come first.", enHook: "Center the lived experience of people with cerebral palsy"),
    .init(id: "10-08", trDescription: "Uluslararası Lezbiyen Günü, lezbiyenlerin yaşamlarını, kültürünü ve dayanışmasını görünür kılan topluluk temelli bir kutlamadır.", trHook: "Görünürlüğünü ve neşesini kutladığın kişiye gönder", enDescription: "International Lesbian Day is a community-led celebration of lesbian lives, culture, visibility and solidarity.", enHook: "Send to someone whose visibility and joy you celebrate"),
    .init(id: "10-13", trDescription: "Afet riskini azaltmak, tehlike gerçekleşmeden önce güvenli yapılar, erken uyarı, erişilebilir planlar ve topluluk hazırlığı kurmak demektir.", trHook: "Hazırlık bilgisini korkutmadan, doğrulanmış biçimde paylaş", enDescription: "Disaster risk reduction means building safer infrastructure, early warning, accessible plans and community preparedness before hazards become disasters.", enHook: "Share verified preparedness without spreading fear"),
    .init(id: "10-17", trDescription: "Yoksulluk kişisel bir başarısızlık değil; haklara, gelire, barınmaya ve hizmetlere erişimi sınırlayan yapısal eşitsizliklerle bağlantılıdır.", trHook: "Yoksulluk yaşayanların onurunu merkeze alarak paylaş", enDescription: "Poverty is not a personal failure; it is connected to structural inequality that restricts access to rights, income, housing and services.", enHook: "Share with the dignity of people experiencing poverty at the center"),
    .init(id: "10-22", trDescription: "Kekemelik konuşmanın doğal çeşitlerinden biridir; sabırla dinlemek ve kişi istemedikçe cümlesini tamamlamamak saygılı iletişimin basit bir parçasıdır.", trHook: "Kekemeliği olan kişilerin kendi sesini öne çıkar", enDescription: "Stuttering is a natural variation of speech; listening patiently and not finishing someone's sentences unless asked are simple forms of respect.", enHook: "Center the voices of people who stutter"),
    .init(id: "10-26", trDescription: "İnterseks bireyler cinsiyet özelliklerindeki doğal çeşitliliklerle doğar; bedensel özerklik, doğru bilgi ve damgalanmadan yaşama hakkı esastır.", trHook: "İnterseks bireylerin kendi seslerini özenle büyüt", enDescription: "Intersex people are born with natural variations in sex characteristics; bodily autonomy, accurate information and freedom from stigma are essential.", enHook: "Amplify intersex voices with care"),
    .init(id: "11-02", trDescription: "Gazetecilere yönelik saldırıların cezasız kalması yalnızca bireyleri değil, toplumun bilgiye erişimini de tehdit eder; hesap verebilirlik basın özgürlüğünün parçasıdır.", trHook: "Gazetecilerin güvenliğini ve hesap verebilirliği gözeterek paylaş", enDescription: "Impunity for attacks on journalists threatens both individuals and the public's access to information; accountability is part of press freedom.", enHook: "Share with journalists' safety and accountability in focus"),
    .init(id: "11-05", trDescription: "Tsunami bilinci; doğal uyarı işaretlerini tanımayı, resmî uyarıları izlemeyi ve kıyıdan yüksek bölgelere giden tahliye rotasını önceden bilmeyi gerektirir.", trHook: "Doğrulanmış hazırlık bilgisini korkutmadan paylaş", enDescription: "Tsunami awareness means recognizing natural warning signs, following official alerts and knowing evacuation routes from the coast to higher ground before an emergency.", enHook: "Share verified preparedness without spreading fear"),
    .init(id: "11-06", trDescription: "Savaşın zararı insanlarla sınırlı kalmaz; su, toprak ve ekosistemlerde yıllarca süren tahribat yaratır ve sivillerin yaşam koşullarını ağırlaştırır.", trHook: "Savaşın çevresel ve insani bedelini saygıyla paylaş", enDescription: "War harms more than people; it can damage water, soil and ecosystems for years and deepen the hardship faced by civilians.", enHook: "Share the environmental and human cost of war with care"),
    .init(id: "11-11", trDescription: "11 Kasım, 1918 Ateşkesi'nin yıldönümünde farklı ülkelerde savaşta hayatını kaybedenleri, gazileri ve barışın bedelini farklı adlarla anıyor.", trHook: "Kayıpları ve barışın değerini saygıyla an", enDescription: "On the anniversary of the 1918 Armistice, 11 November is observed under different names to remember war dead, veterans and the cost of peace.", enHook: "Remember loss and the value of peace with care"),
    .init(id: "11-24", trDescription: "Yapışık ikizlik nadir bir doğumsal durumdur ve her bireyin tıbbi koşulları ile yaşam deneyimi farklıdır; merak değil saygı ve nitelikli bakım öne çıkmalıdır.", trHook: "Yapışık ikizlerin onurunu ve kendi deneyimlerini merkeze al", enDescription: "Conjoined twinning is a rare congenital condition, and each person's medical circumstances and lived experience differ; dignity and quality care should come before curiosity.", enHook: "Center the dignity and lived experience of conjoined twins"),
    .init(id: "11-29", trDescription: "Bu Birleşmiş Milletler günü, Filistin halkının devredilemez haklarını, insan onurunu ve kendi geleceğini belirleme hakkını destekleyen dayanışmayı görünür kılar.", trHook: "Filistinlilerin haklarını ve insan onurunu merkeze alarak paylaş", enDescription: "This United Nations day expresses solidarity with the inalienable rights, human dignity and self-determination of the Palestinian people.", enHook: "Share by centering Palestinian rights and human dignity"),
    .init(id: "12-09", trDescription: "Yolsuzluk kamu kaynaklarını ve güveni aşındırır; şeffaflık, bağımsız denetim ve hesap verebilirlik herkesin hakkı olan hizmetleri korur.", trHook: "Şeffaflık ve hesap verebilirlik talebini paylaş", enDescription: "Corruption erodes public resources and trust; transparency, independent oversight and accountability protect services that belong to everyone.", enHook: "Share the call for transparency and accountability"),
    .init(id: "12-14", trDescription: "Sömürgeciliğe Karşı Uluslararası Gün, sömürgeciliğin süren siyasi, ekonomik ve kültürel sonuçlarını görünür kılarak halkların kendi kaderini tayin hakkını savunur.", trHook: "Sömürgecilikten etkilenen halkların kendi sesini merkeze al", enDescription: "The International Day against Colonialism highlights colonialism's continuing political, economic and cultural consequences and affirms peoples' right to self-determination.", enHook: "Center the voices of peoples affected by colonialism"),
    .init(id: "12-18", trDescription: "Göçmenlerin hakları, göç statülerinden bağımsızdır; güvenli çalışma, adalete erişim ve ayrımcılıktan korunma insan onurunun parçasıdır.", trHook: "Göçmenlerin haklarını ve kendi seslerini özenle paylaş", enDescription: "Migrants' rights do not depend on migration status; safe work, access to justice and protection from discrimination are matters of human dignity.", enHook: "Share migrants' rights and voices with care"),
    .init(id: "12-28", trDescription: "Masum Çocuklar Günü, Hristiyan geleneğinde İncil'deki Kral Hirodes anlatısında öldürülen çocukları anan dinî bir gündür.", trHook: "Yalnızca dinî ve tarihsel bağlamıyla, saygıyla paylaş", enDescription: "The Day of the Holy Innocents is a Christian observance remembering the children killed in the Gospel account of King Herod.", enHook: "Share respectfully and only with its religious and historical context")
]

private let sources: [String: SourcePatch] = [
    "02-01": .init(organization: "World Hijab Day", url: "https://worldhijabday.com/"),
    "02-04": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "02-19": .init(organization: "US Naval History and Heritage Command", url: "https://www.history.navy.mil/about-us/leadership/director/directors-corner/h-grams/h-gram-042/h-042-1.html"),
    "02-25": .init(organization: "Official Gazette of the Republic of the Philippines", url: "https://www.officialgazette.gov.ph/featured/edsa-the-original-people-power-revolution/"),
    "03-12": .init(organization: "Reporters Without Borders", url: "https://rsf.org/en/world-day-against-cyber-censorship"),
    "03-31": .init(organization: "GLAAD", url: "https://glaad.org/tdov/"),
    "04-08": .init(organization: "Council of Europe", url: "https://www.coe.int/en/web/roma-and-travellers/international-roma-day"),
    "04-14": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-chagas-disease-day"),
    "04-28": .init(organization: "International Labour Organization", url: "https://www.ilo.org/resource/world-day-28-april"),
    "05-01": .init(organization: "International Labour Organization", url: "https://www.ilo.org/"),
    "05-23": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "05-31": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-no-tobacco-day"),
    "06-02": .init(organization: "Global Network of Sex Work Projects", url: "https://www.nswp.org/event/international-sex-workers-day"),
    "06-13": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "06-28": .init(organization: "US National Park Service", url: "https://www.nps.gov/ston/index.htm"),
    "07-18": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "07-25": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns/world-drowning-prevention-day"),
    "08-01": .init(organization: "World Health Organization", url: "https://www.who.int/campaigns"),
    "08-31": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "09-18": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "09-26": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "10-06": .init(organization: "World Cerebral Palsy Day", url: "https://worldcpday.org/"),
    "10-13": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "10-17": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "10-22": .init(organization: "International Stuttering Association", url: "https://isastutter.org/what-we-do/isad/"),
    "10-26": .init(organization: "interACT", url: "https://interactadvocates.org/intersex-awareness-day/"),
    "11-02": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "11-05": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "11-06": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "11-11": .init(organization: "Commonwealth War Graves Commission", url: "https://www.cwgc.org/our-work/commemorations/armistice-day/"),
    "11-24": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "11-29": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "12-09": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "12-14": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks"),
    "12-18": .init(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks")
]

private let officialIDs: Set<String> = [
    "02-04", "04-14", "04-28", "05-23", "05-31", "06-13", "07-18",
    "07-25", "08-31", "09-18", "09-26", "10-13", "10-17", "11-02",
    "11-05", "11-06", "11-24", "11-29", "12-09", "12-14", "12-18"
]
private let remembranceIDs: Set<String> = ["02-19", "09-26", "11-06", "11-11", "12-28"]
private let healthIDs: Set<String> = ["04-14", "05-23", "05-31", "07-25", "08-01", "10-06", "10-22", "11-24"]
private let cultureIDs: Set<String> = ["02-01", "02-23", "10-08", "12-28"]
private let standardIDs: Set<String> = ["02-04", "02-23", "02-25", "03-12", "05-01", "06-28", "07-18", "10-08", "12-09"]
private let targetIDs = Set(copy.map(\.id))

guard copy.count == 38, targetIDs.count == copy.count else {
    fatalError("Expected 38 unique contextual records")
}
guard officialIDs.isSubset(of: Set(sources.keys)) else {
    fatalError("Every official contextual record needs a reviewed source")
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
        fatalError("\(language) corpus is missing contextual records")
    }
    for index in days.indices {
        guard let patch = byID[days[index].id] else { continue }
        days[index].description = language == "tr" ? patch.trDescription : patch.enDescription
        days[index].sharingHook = language == "tr" ? patch.trHook : patch.enHook
    }
    try render(days).write(to: url, atomically: true, encoding: .utf8)
}

private func category(for id: String) -> String {
    if remembranceIDs.contains(id) { return "remembrance" }
    if healthIDs.contains(id) { return "health-and-awareness" }
    if cultureIDs.contains(id) { return "culture-and-arts" }
    return "civil-society"
}

private func symbol(for id: String) -> String {
    if remembranceIDs.contains(id) { return "🕯️" }
    if healthIDs.contains(id) { return "🫶" }
    let symbols: [String: String] = [
        "02-01": "🧕", "02-04": "🤝", "02-23": "📜", "02-25": "🕊️",
        "03-12": "🌐", "03-31": "🏳️‍⚧️", "04-08": "☸️", "04-28": "🦺",
        "05-01": "✊", "06-02": "🫶", "06-13": "☀️", "06-28": "🏳️‍🌈",
        "07-18": "🤝", "08-31": "🌍", "09-18": "⚖️", "10-08": "🏳️‍🌈",
        "10-13": "🛟", "10-17": "🤝", "10-26": "🟡", "11-02": "📰",
        "11-05": "🌊", "11-29": "🕊️", "12-09": "⚖️", "12-14": "🕊️",
        "12-18": "🧳"
    ]
    return symbols[id] ?? "🫶"
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
        records[index]["category"] = category(for: id)
        records[index]["sensitivity"] = remembranceIDs.contains(id) ? "remembrance" : (standardIDs.contains(id) ? "standard" : "considerate")
        records[index]["shareability"] = remembranceIDs.contains(id) ? 1 : (standardIDs.contains(id) ? (id == "02-23" ? 3 : 4) : 2)
        records[index]["audience"] = standardIDs.contains(id) ? ["community"] : ["careful-sharing"]
        records[index]["authority"] = officialIDs.contains(id) ? "official" : (cultureIDs.contains(id) || id == "02-19" || id == "11-11" ? "cultural" : "editorial")
        records[index]["scope"] = id == "02-23" ? "culture-specific" : "international"
        records[index]["symbol"] = symbol(for: id)
        if let source = sources[id] {
            records[index]["source"] = [
                "organization": source.organization,
                "url": source.url,
                "checkedAt": "2026-08-14"
            ]
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
print("Curated 38 context-sensitive records")
