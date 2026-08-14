#!/usr/bin/env swift

import Foundation

// Hand-written, person-to-person copy for the light editorial days that form
// WhaDay's organic sharing loop. These are prompts, not claimed official dates.

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
    .init(id: "01-08", trDescription: "Takvimin bahanesi hazır: telefonu biraz uzağa bırak, suyu ısıt ve günü köpüklerin içinde sessize al.", trHook: "Bir saat kaybolup dinlenmesi gereken kişiye gönder", enDescription: "The calendar has supplied the excuse: put the phone away, run the water and mute the day under a layer of bubbles.", enHook: "Send to someone who needs an hour off the grid"),
    .init(id: "01-09", trDescription: "Kışın kapı koluyla arandaki minik elektrik savaşı bugün resmiyet kazandı. Saçlar havadaysa bilim çalışıyor.", trHook: "Her dokunduğunda kıvılcım çıkaran arkadaşına gönder", enDescription: "That tiny winter battle between you and every doorknob is official today. If your hair is floating, science is working.", enHook: "Send to the friend who sparks on contact"),
    .init(id: "01-10", trDescription: "Ev bitkileri sessiz ev arkadaşlarıdır: biraz ışık, doğru miktarda su ve arada bir yaprak kontrolüyle karşılığını verirler.", trHook: "Evi küçük bir ormana çeviren kişiye gönder", enDescription: "Houseplants are quiet roommates: give them light, the right amount of water and an occasional leaf check, and they give plenty back.", enHook: "Send to the person turning home into a tiny jungle"),
    .init(id: "01-11", trDescription: "Sade, kahveli, kakaolu ya da bitkisel eşlikçisiyle: bugün bardağı çocukluk anılarına kaldırmak için küçük bir bahane.", trHook: "Kurabiyenin yanına mutlaka süt koyan kişiye gönder", enDescription: "Plain, with coffee, cocoa or a plant-based companion: today is a small excuse to raise a glass to childhood comfort.", enHook: "Send to someone who insists cookies need milk"),
    .init(id: "01-12", trDescription: "Kızıl saçları kutlamanın kuralı basit: iltifat serbest, temas yalnızca karşılıklı istek varsa. Renk zaten bütün ilgiyi topluyor.", trHook: "En sevdiğin kızıl saçlı kişiye, rızayla, gönder", enDescription: "The rule for celebrating red hair is simple: compliments are welcome; contact only belongs where it is wanted. The colour already owns the room.", enHook: "Send, respectfully, to your favourite redhead"),
    .init(id: "01-15", trDescription: "Şapka bazen hava koşulu, bazen karakter gelişimidir. Bugün en iddialı olanı seçmek için takvimden izin çıktı.", trHook: "Her kombini bir şapkayla tamamlayan kişiye gönder", enDescription: "A hat is sometimes weather protection and sometimes character development. Today the calendar permits the boldest one.", enHook: "Send to the person who finishes every look with a hat"),
    .init(id: "01-17", trDescription: "Çocukların 'ya şöyle olsaydı?' sorusu çoğu icadın başladığı yere benzer. Bugün küçük fikirleri ciddiye alma günü.", trHook: "Aklı sürekli yeni fikirlerle dolu bir çocuğa gönder", enDescription: "A child's 'what if?' sounds a lot like the beginning of an invention. Today is for taking small ideas seriously.", enHook: "Send to a young inventor whose mind never sits still"),
    .init(id: "01-22", trDescription: "Puantiye, kıyafetin noktalama işaretidir: cümle sade olsa bile enerjiyi bir anda değiştirir.", trHook: "Dolabında mutlaka puantiyeli bir şey olan kişiye gönder", enDescription: "Polka dots are punctuation for an outfit: even when the sentence is simple, they change its whole energy.", enHook: "Send to someone who definitely owns something dotted"),
    .init(id: "01-23", trDescription: "Tatlı ya da tuzlu, çıtır kenarlı bir turta masaya geldiğinde günün geri kalanı ikincil mesele olur.", trHook: "Son dilimi paylaşabileceğin kişiye gönder", enDescription: "Sweet or savoury, once a pie with crisp edges reaches the table, the rest of the day becomes a secondary concern.", enHook: "Send to someone you would share the last slice with"),
    .init(id: "02-07", trDescription: "Sevgililer Haftası'nın ilk bahanesi bir gül; ama asıl mesele, 'seni düşündüm' demenin küçük ve zarif bir yolunu bulmak.", trHook: "Bugün durup dururken gül alasın gelen kişiye gönder", enDescription: "Valentine's Week begins with a rose, but the real point is finding a small, graceful way to say, 'I thought of you.'", enHook: "Send to someone you suddenly want to buy a rose for"),
    .init(id: "02-08", trDescription: "Adında evlilik teklifi var diye yüzük şart değil; birlikte bir yolculuk, kahve ya da gelecek planı önermek de gayet geçerli.", trHook: "Birlikte yeni bir şeye evet diyeceğin kişiye gönder", enDescription: "Despite the name, no ring is required; proposing a trip, a coffee or a shared plan for the future counts too.", enHook: "Send to someone you would say yes to a new adventure with"),
    .init(id: "02-18", trDescription: "Piller sessizce hayatı taşır; kumandadan acil durum fenerine kadar. Bugün çekmeceyi kontrol edip bitenleri doğru noktaya bırakma günü.", trHook: "Pili yüzde birde yaşamayı seven kişiye gönder", enDescription: "Batteries quietly carry daily life, from remotes to emergency torches. Check the drawer and recycle the dead ones properly today.", enHook: "Send to someone who lives permanently at one percent"),
    .init(id: "03-02", trDescription: "Bir kurtarma kedisi eve yalnızca pati izi değil, kendi ritmini ve tuhaf küçük kurallarını da getirir.", trHook: "Telefonu kedi fotoğraflarıyla dolu kişiye gönder", enDescription: "A rescue cat brings more than paw prints into a home; it brings a rhythm and a set of wonderfully strange little rules.", enHook: "Send to someone whose camera roll belongs to a cat"),
    .init(id: "03-07", trDescription: "Kahvaltı gevreği hızlı bir öğün, gece atıştırması ve bazen çocukluğa açılan çıtır bir kapıdır.", trHook: "Kâseye önce süt mü gevrek mi koyduğunu tartışacağın kişiye gönder", enDescription: "Cereal is a quick breakfast, a midnight snack and sometimes a crunchy door straight back to childhood.", enHook: "Send to someone you would debate cereal-first versus milk-first with"),
    .init(id: "03-29", trDescription: "Piyano Günü yılın 88. gününe yakın kutlanır; tuş sayısına küçük bir selam. Bugün tek bir parça bile odayı değiştirebilir.", trHook: "Sana ilk üç notadan şarkıyı bulan kişiye gönder", enDescription: "Piano Day falls around the 88th day of the year, a nod to its keys. Even one piece can change the shape of a room today.", enHook: "Send to someone who names a song in three notes"),
    .init(id: "04-03", trDescription: "Bazen çözüm daha çok düşünmek değil, gürültüyü azaltmaktır. Bugün tek bir meseleyi olduğu gibi görmeye yer aç.", trHook: "Kafanı bir cümleyle netleştiren kişiye gönder", enDescription: "Sometimes clarity comes not from more thinking but from less noise. Make room to see one thing exactly as it is today.", enHook: "Send to someone who clears your head in one sentence"),
    .init(id: "04-09", trDescription: "Günün ortasına küçük bir virgül koy: omuzlarını indir, nefesini fark et ve hemen cevap vermek zorunda olmadığını hatırla.", trHook: "Birlikte biraz yavaşlaman gereken kişiye gönder", enDescription: "Put a small comma in the middle of the day: lower your shoulders, notice your breath and remember you do not have to answer immediately.", enHook: "Send to someone you need to slow down with"),
    .init(id: "04-10", trDescription: "Kardeşlik aynı çocukluğu farklı hatırlamak, eski şakaları hâlâ anlamak ve gerektiğinde tek mesajla yanında belirmektir.", trHook: "Aynı evin farklı hikâyesini taşıyan kardeşine gönder", enDescription: "Siblings remember the same childhood differently, still understand the oldest jokes and can appear with a single message when it matters.", enHook: "Send to the sibling carrying another version of your story"),
    .init(id: "04-19", trDescription: "İç güç her zaman yüksek sesli değildir; bazen yeniden denemek, bazen sınır koymak, bazen de bugünlük durabilmektir.", trHook: "Sessiz gücüne hayran olduğun kişiye gönder", enDescription: "Inner strength is not always loud; sometimes it is trying again, setting a boundary or knowing when to stop for today.", enHook: "Send to someone whose quiet strength you admire"),
    .init(id: "04-27", trDescription: "Bazı insanlarla konuşma kaldığı yerden devam eder; aradan aylar geçse bile ilk cümlede mesafe kapanır.", trHook: "Uzun süredir konuşmadığın hâlde hâlâ yakın hissettiğine gönder", enDescription: "With some people, conversation resumes exactly where it paused; even after months, the distance closes in the first sentence.", enHook: "Send to someone who still feels close after a long silence"),
    .init(id: "05-07", trDescription: "Şükran büyük cümle istemez. Tam zamanında gelen bir mesajı, iyi demlenmiş çayı ya da yanında duran kişiyi fark etmekle başlar.", trHook: "Bugün hayatında olduğu için teşekkür etmek istediğine gönder", enDescription: "Gratitude does not need a grand speech. It begins by noticing a timely message, a good cup of tea or the person who stayed.", enHook: "Send to someone you are grateful to have in your life"),
    .init(id: "05-11", trDescription: "Dikkat, günün en kıt kaynağı. Bugün bir işi yaparken yalnızca orada kalmayı dene; sekmeleri sonra da açabilirsin.", trHook: "Seni ana geri getiren kişiye gönder", enDescription: "Attention is the day's scarcest resource. Try staying with one thing while you do it; the other tabs can wait.", enHook: "Send to someone who brings you back to the present"),
    .init(id: "05-13", trDescription: "Büyümek düz bir çizgi değildir; bazen hızlanır, bazen geri dönüp aynı dersi daha nazikçe öğrenirsin.", trHook: "Ne kadar yol aldığını bazen unutan kişiye gönder", enDescription: "Growth is not a straight line; sometimes it accelerates, and sometimes you return to learn the same lesson more gently.", enHook: "Send to someone who forgets how far they have come"),
    .init(id: "05-14", trDescription: "Kendine bakım yalnızca mum yakmak değil; su içmek, randevu almak, hayır demek ve uykuyu ertelememek de bu listenin içinde.", trHook: "Kendini listenin sonuna koyan kişiye gönder", enDescription: "Self-care is not only candles; drinking water, making the appointment, saying no and protecting sleep all belong on the list.", enHook: "Send to someone who keeps putting themselves last"),
    .init(id: "05-26", trDescription: "Her gün büyük bir keşif sunmaz; bazen günün harikası ışığın duvara düşüşü, iyi bir cümle ya da tam zamanında esen rüzgârdır.", trHook: "Küçük şeyleri fark etme yeteneğini sevdiğin kişiye gönder", enDescription: "Not every day offers a grand discovery; sometimes its wonder is light on a wall, one good sentence or a breeze arriving on time.", enHook: "Send to someone whose eye for small wonders you love"),
    .init(id: "06-09", trDescription: "Denge her şeye eşit süre vermek değil; bugün neyin senden daha fazla ilgi istediğini doğru tartabilmektir.", trHook: "Hayatın terazisini birlikte düzelttiğin kişiye gönder", enDescription: "Balance is not giving everything equal time; it is judging what needs more of you today.", enHook: "Send to someone who helps steady your scales"),
    .init(id: "06-22", trDescription: "Yağmur ormanları iklimi, su döngülerini ve benzersiz canlı çeşitliliğini taşır. Uzak görünseler de gündelik hayatımıza bağlılar.", trHook: "Birlikte ormanda kaybolmak isteyeceğin kişiye gönder", enDescription: "Rainforests sustain climate, water cycles and extraordinary biodiversity. They may feel distant, but daily life is tied to them.", enHook: "Send to someone you would happily get lost in a forest with"),
    .init(id: "07-22", trDescription: "22/7, pi sayısına şaşırtıcı derecede yakın bir kesir. Matematiğin bazen ciddi, bazen de takvim kadar oyunbaz olduğunun kanıtı.", trHook: "Şakaları bile formülle anlatan kişiye gönder", enDescription: "22/7 is a fraction remarkably close to pi: proof that mathematics can be serious and still playful enough for a calendar joke.", enHook: "Send to someone who explains even jokes with equations"),
    .init(id: "07-26", trDescription: "Esperanto, farklı dilleri konuşan insanların daha kolay buluşabilmesi için tasarlanmış bir dil; bugün merhaba demenin 'saluton' hâli.", trHook: "Seninle her dilde anlaşabilen kişiye gönder", enDescription: "Esperanto was designed to make meeting across languages easier; today, hello comes in the form of 'saluton.'", enHook: "Send to someone who understands you in every language"),
    .init(id: "07-27", trDescription: "Finlandiya'nın Uykucu Günü geleneğinde evin en geç kalkanı şakaların hedefi olur. Alarmı erteleyenler bugün dikkatli uyusun.", trHook: "Beş alarmdan önce uyanmayan kişiye gönder", enDescription: "Finland's Sleepy Head Day tradition playfully targets the last person in the house to wake. Serial snoozers, sleep carefully.", enHook: "Send to someone who needs five alarms"),
    .init(id: "08-03", trDescription: "Yaratıcı ruh doğru malzemeyi beklemez; elindeki not, ses, renk ya da fikirle küçük bir şey başlatır.", trHook: "Bir fikri hemen dünyaya çıkaran kişiye gönder", enDescription: "A creative spirit does not wait for perfect materials; it starts something small with the note, sound, colour or idea already at hand.", enHook: "Send to someone who brings ideas into the world"),
    .init(id: "08-04", trDescription: "Olumlu enerji, her şey yolundaymış gibi davranmak değil; zor günün içinde bile işe yarayan küçük ihtimali görebilmektir.", trHook: "Odaya girdiğinde havayı değiştiren kişiye gönder", enDescription: "Positive energy is not pretending everything is fine; it is noticing the small possibility that still works inside a hard day.", enHook: "Send to someone who changes the room when they enter"),
    .init(id: "08-05", trDescription: "Kişisel güç, kontrol edemediğin şeyleri zorlamak yerine kendi kararının başladığı yeri tanımaktır.", trHook: "Kendi gücünü yeniden hatırlaması gereken kişiye gönder", enDescription: "Personal power begins by recognizing where your own choice starts instead of forcing what you cannot control.", enHook: "Send to someone who needs reminding of their own strength"),
    .init(id: "08-07", trDescription: "Bilinçli yaşamak her an kusursuz farkındalık değildir; otomatik pilottan çıktığını fark edip tekrar seçim yapabilmektir.", trHook: "Hayatı aceleye getirmeden yaşayan kişiye gönder", enDescription: "Mindful living is not perfect awareness at every moment; it is noticing autopilot and choosing again.", enHook: "Send to someone who refuses to rush through life"),
    .init(id: "08-16", trDescription: "Şükran bazen geriye bakınca görünür: atlatılan dönem, açılan kapı ve yol boyunca elini bırakmayan insanlar.", trHook: "İyi ki yolum kesişti dediğin kişiye gönder", enDescription: "Gratitude sometimes appears in hindsight: the season survived, the door that opened and the people who never let go along the way.", enHook: "Send to someone you are glad life placed in your path"),
    .init(id: "08-18", trDescription: "Kendini keşfetmek gizli tek bir cevabı bulmak değil; neye yaklaştığını ve neden uzaklaştığını merakla izlemektir.", trHook: "Kendin olmana alan açan kişiye gönder", enDescription: "Self-discovery is not finding one hidden answer; it is staying curious about what draws you closer and what makes you step away.", enHook: "Send to someone who gives you room to be yourself"),
    .init(id: "08-25", trDescription: "Bazı günlerin üretkenlik hedefi yalnızca iyi bir kahkaha olmalı. Bugün o hedef fazlasıyla yeterli.", trHook: "En saçma anda seni güldüren kişiye gönder", enDescription: "Some days deserve a single productivity goal: one excellent laugh. Today, that is more than enough.", enHook: "Send to someone who makes you laugh at the worst possible time"),
    .init(id: "08-28", trDescription: "Enerji her zaman kendiliğinden gelmez; bazen kısa bir yürüyüşten, sevdiğin şarkıdan ya da doğru kişiden ödünç alınır.", trHook: "Pillerini tek mesajla dolduran kişiye gönder", enDescription: "Energy does not always arrive on its own; sometimes you borrow it from a short walk, a favourite song or the right person.", enHook: "Send to someone who recharges you with one message"),
    .init(id: "09-03", trDescription: "Gökdelenler mühendislik kadar hayal gücü de taşır; zeminden bakınca baş döndüren fikir, kat kat gerçeğe dönüşür.", trHook: "Şehirde hep yukarı bakarak yürüyen kişiye gönder", enDescription: "Skyscrapers hold imagination as much as engineering; a dizzying idea viewed from the ground becomes real, floor by floor.", enHook: "Send to someone who always looks up while walking through a city"),
    .init(id: "09-06", trDescription: "Bir kitap bazen yeni bir dünya, bazen ihtiyacın olan tek cümledir. Bugün yarım bıraktığın sayfaya dönmek için iyi gün.", trHook: "Sana en iyi kitapları öneren kişiye gönder", enDescription: "A book can be a new world or the one sentence you needed. Today is a good day to return to the page you left unfinished.", enHook: "Send to the person with the best book recommendations"),
    .init(id: "09-13", trDescription: "Roald Dahl'ın dünyasında dev şeftaliler, çikolata fabrikaları ve kuralları ters yüz eden çocuklar var; bugün hayal gücü biraz taşabilir.", trHook: "Çocukken aynı kitabı defalarca okuyan kişiye gönder", enDescription: "Roald Dahl's worlds hold giant peaches, chocolate factories and children who overturn the rules; let imagination spill over today.", enHook: "Send to someone who reread the same childhood book endlessly"),
    .init(id: "10-03", trDescription: "3 Ekim, Mean Girls evreninde tek bir soruyla tarihe geçti: 'Bugün günlerden ne?' Pembe giymek isteğe bağlı.", trHook: "Alıntılarla konuştuğun Mean Girls hayranına gönder", enDescription: "October 3 entered Mean Girls history with one simple question: 'What day is it?' Wearing pink remains optional.", enHook: "Send to the Mean Girls fan you communicate with in quotes"),
    .init(id: "10-19", trDescription: "Bilgelik her soruya cevap vermek değil; hangi sorunun aceleye gelmediğini ve ne zaman sessizce dinlemek gerektiğini bilmektir.", trHook: "Az konuşup çok şey anlatan kişiye gönder", enDescription: "Wisdom is not answering every question; it is knowing which ones should not be rushed and when to listen quietly.", enHook: "Send to someone who says a lot with very few words"),
    .init(id: "10-30", trDescription: "Potansiyel bitmiş bir sonuç değil, henüz denemediğin yolların toplamıdır. Bugün birine başlamak yeterli.", trHook: "Kendine koyduğu sınırdan daha büyük olan kişiye gönder", enDescription: "Potential is not a finished result; it is the sum of paths not tried yet. Starting one today is enough.", enHook: "Send to someone bigger than the limits they set themselves"),
    .init(id: "11-03", trDescription: "Aklına iyi bir şey geldiyse sahibine söyle. İçinden edilen teşekkür güzeldir; gönderilen teşekkür ilişkiyi değiştirir.", trHook: "Uzun zamandır teşekkür etmediğin kişiye gönder", enDescription: "If a kind thought arrives, tell its owner. Silent gratitude is lovely; delivered gratitude changes a relationship.", enHook: "Send to someone you have not thanked in far too long"),
    .init(id: "11-04", trDescription: "Işık olmak her zaman yolu bilmek değildir; bazen karanlıkta birinin yanında yeterince uzun kalmaktır.", trHook: "Zor zamanda yanında kalan kişiye gönder", enDescription: "Being a light does not always mean knowing the way; sometimes it means staying beside someone in the dark long enough.", enHook: "Send to someone who stayed beside you through a hard time"),
    .init(id: "11-23", trDescription: "Umut, her şeyin kolay olacağına inanmak değil; zor olsa da sonraki adımın hâlâ mümkün olduğunu bilmektir.", trHook: "Hayallerini yarıda bırakmamasını istediğin kişiye gönder", enDescription: "Hope is not believing everything will be easy; it is knowing the next step remains possible even when it is hard.", enHook: "Send to someone whose dreams you do not want them to abandon"),
    .init(id: "11-28", trDescription: "Dönüşüm bazen dışarıdan fark edilmez; aynı durumda bu kez farklı bir seçim yaptığında başlar.", trHook: "Değişimine yakından tanık olduğun kişiye gönder", enDescription: "Transformation is not always visible from the outside; it begins when the same situation meets a different choice.", enHook: "Send to someone whose growth you have witnessed up close"),
    .init(id: "12-19", trDescription: "Sert şeker biraz sabır ister: çiğnemeye çalışırsan yenilir, beklersen çocukluk tadı yavaşça ortaya çıkar.", trHook: "Çantasında her zaman şeker taşıyan kişiye gönder", enDescription: "Hard candy rewards patience: bite too soon and it wins; wait, and the taste of childhood slowly appears.", enHook: "Send to someone who always carries sweets in their bag"),
    .init(id: "12-27", trDescription: "Meyveli kek, tatil masasının en tartışmalı karakteri olabilir. Seveni sadık, sevmeyeni son derece nettir.", trHook: "Meyveli keki savunurken yalnız kalan kişiye gönder", enDescription: "Fruitcake may be the holiday table's most divisive character. Its fans are loyal and its critics remarkably certain.", enHook: "Send to the person left alone defending fruitcake")
]

private let relationshipIDs: Set<String> = [
    "01-12", "02-07", "02-08", "04-10", "04-27", "05-07", "05-13",
    "06-09", "08-16", "08-18", "08-25", "11-03", "11-04", "11-23"
]
private let foodIDs: Set<String> = ["01-11", "01-23", "03-07", "12-19", "12-27"]
private let natureIDs: Set<String> = ["01-10", "03-02", "06-22"]
private let cultureIDs: Set<String> = ["03-29", "09-06", "09-13", "10-03"]
private let scienceIDs: Set<String> = ["01-09", "01-17", "02-18", "07-22"]
private let targetIDs = Set(copy.map(\.id))

guard copy.count == 50, targetIDs.count == copy.count else {
    fatalError("Expected 50 unique shareable records")
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
        fatalError("\(language) corpus is missing shareable records")
    }
    for index in days.indices {
        guard let patch = byID[days[index].id] else { continue }
        days[index].description = language == "tr" ? patch.trDescription : patch.enDescription
        days[index].sharingHook = language == "tr" ? patch.trHook : patch.enHook
    }
    try render(days).write(to: url, atomically: true, encoding: .utf8)
}

private func category(for id: String) -> String {
    if relationshipIDs.contains(id) { return "relationships" }
    if foodIDs.contains(id) { return "food-and-drink" }
    if natureIDs.contains(id) { return "animals-and-nature" }
    if cultureIDs.contains(id) { return "culture-and-arts" }
    if scienceIDs.contains(id) { return "science-and-curiosity" }
    return "playful"
}

private func curateMetadata() throws {
    let url = root.appendingPathComponent("WhaDayNative/Data/metadata.json")
    guard var records = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [[String: Any]] else {
        fatalError("metadata.json is not an array")
    }
    var updated = 0
    for index in records.indices {
        guard let id = records[index]["id"] as? String, targetIDs.contains(id) else { continue }
        guard records[index]["authority"] as? String == "editorial" else {
            fatalError("Refusing to turn non-editorial record into a WhaDay prompt: \(id)")
        }
        records[index]["reviewState"] = "curated"
        records[index]["category"] = category(for: id)
        records[index]["sensitivity"] = "standard"
        records[index]["shareability"] = 5
        records[index]["audience"] = relationshipIDs.contains(id) ? ["friend", "partner"] : ["friend", "community"]
        records[index]["scope"] = "whaday-editorial"
        records[index].removeValue(forKey: "source")
        updated += 1
    }
    guard updated == 50 else { fatalError("Expected 50 metadata updates, wrote \(updated)") }
    let output = try JSONSerialization.data(withJSONObject: records, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    try output.write(to: url, options: .atomic)
}

try curateLocalized("tr")
try curateLocalized("en")
try curateMetadata()
print("Curated 50 high-shareability editorial records")
