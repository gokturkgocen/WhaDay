#!/usr/bin/env swift

import Foundation

// Editorial review for the remaining January-June institutional and civic
// records, plus two WhaDay prompts occupying dates without a fixed observance.

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
    .init(id: "01-26", trDescription: "Temiz enerjiye geçiş; iklimi korurken güvenilir, erişilebilir ve uygun maliyetli enerjiye herkesin ulaşabilmesini de gerektirir.", trHook: "Enerjinin geleceğini önemseyen biriyle paylaş", enDescription: "The clean-energy transition must protect the climate while making reliable, accessible and affordable energy available to everyone.", enHook: "Share with someone who cares about the future of energy"),
    .init(id: "01-28", trDescription: "Barış içinde bir arada yaşamak farklılıkları yok saymak değil; eşit haklar, güven ve gündelik diyalog için ortak zemin kurmaktır.", trHook: "Farklılıklarla birlikte yaşamaya inanan birine gönder", enDescription: "Peaceful coexistence does not erase differences; it builds common ground through equal rights, trust and everyday dialogue.", enHook: "Send to someone who believes differences can live together"),
    .init(id: "01-30", trDescription: "Şiddetsizlik ve Barış İçin Okul Günü, eğitimin yalnızca bilgi değil; çatışmayı diyalogla çözme kültürü de taşıyabileceğini hatırlatır.", trHook: "Barışı sınıfta büyüten bir öğretmene gönder", enDescription: "School Day of Nonviolence and Peace recalls that education carries more than knowledge; it can also teach a culture of resolving conflict through dialogue.", enHook: "Send to a teacher who grows peace in the classroom"),
    .init(id: "02-02", trDescription: "Sulak alanlar suyu filtreler, taşkınları azaltır ve olağanüstü bir canlı çeşitliliğine yuva olur; kaybolduklarında etkisi kıyılarının çok ötesine ulaşır.", trHook: "Doğayı yalnız manzara olarak görmeyen biriyle paylaş", enDescription: "Wetlands filter water, reduce flooding and shelter extraordinary biodiversity; when they disappear, the effects reach far beyond their shores.", enHook: "Share with someone who sees nature as more than scenery"),
    .init(id: "02-03", trDescription: "Dört Papaz Günü, 1943'te batan Dorchester gemisinde can yeleklerini başkalarına verip hayatını kaybeden dört askerî din görevlisini anar.", trHook: "Cesaret ve fedakârlığı saygıyla an", enDescription: "Four Chaplains Day remembers four military chaplains who gave their lifejackets to others and died when the Dorchester sank in 1943.", enHook: "Remember courage and sacrifice with care"),
    .init(id: "02-10", trDescription: "Mercimek, nohut, fasulye ve diğer baklagiller; protein, lif ve toprağı destekleyen üretim özellikleriyle küçük ama güçlü gıdalardır.", trHook: "Tencerede baklagile her zaman yer açan kişiye gönder", enDescription: "Lentils, chickpeas, beans and other pulses are small but mighty foods, offering protein and fibre while supporting healthier soils.", enHook: "Send to someone who always makes room for pulses in the pot"),
    .init(id: "02-16", trDescription: "16 Şubat, Litvanya Konseyi'nin 1918'de bağımsız devleti yeniden kurduğunu ilan ettiği tarihtir; ülkenin iki modern devlet gününden biridir.", trHook: "Litvanya'yla bağı olan biriyle paylaş", enDescription: "16 February marks the Lithuanian Council's 1918 declaration restoring an independent state and is one of Lithuania's two modern statehood days.", enHook: "Share with someone connected to Lithuania"),
    .init(id: "02-22", trDescription: "Dünya Düşünme Günü, izci kızlar ve kız rehberlerin kurucularının ortak doğum gününde dünya çapındaki hareketin dostluğunu kutlar.", trHook: "Sana yeni yollar açan bir izciye gönder", enDescription: "World Thinking Day celebrates friendship across the global Girl Guide and Girl Scout movement on the shared birthday of its founders.", enHook: "Send to a Guide or Scout who opened new paths for you"),
    .init(id: "02-27", trDescription: "Sivil toplum kuruluşları, toplulukların ihtiyacını görünür kılar, gönüllü emeği örgütler ve kamu politikalarının hesap verebilirliğini güçlendirir.", trHook: "Emeğine güvendiğin bir sivil toplum çalışanına gönder", enDescription: "Civil-society organizations make community needs visible, organize voluntary effort and strengthen public accountability.", enHook: "Send to a civil-society worker whose effort you trust"),
    .init(id: "02-28", trDescription: "Hindistan Ulusal Bilim Günü, C. V. Raman'ın ışığın saçılmasına ilişkin keşfini 28 Şubat 1928'de duyurmasını anıyor.", trHook: "Merakı deneyle sınayan birine gönder", enDescription: "India's National Science Day marks C. V. Raman's announcement of his discovery about the scattering of light on 28 February 1928.", enHook: "Send to someone who tests curiosity through experiment"),
    .init(id: "03-03", trDescription: "Yaban hayatı yalnız uzak coğrafyalardaki türlerden ibaret değil; sağlıklı ekosistemlerin ve insan yaşamının birbirine bağlı olduğunu gösterir.", trHook: "Vahşi yaşamı korumayı önemseyen biriyle paylaş", enDescription: "Wildlife is not only about species in distant places; it shows how healthy ecosystems and human life are connected.", enHook: "Share with someone who cares about protecting wildlife"),
    .init(id: "03-04", trDescription: "Mühendislik; temiz sudan güvenli yapılara, enerjiden ulaşıma kadar sürdürülebilir çözümleri laboratuvardan gündelik hayata taşır.", trHook: "Bir problemi görünce çözüm çizen mühendise gönder", enDescription: "Engineering carries sustainable solutions from the lab into daily life, from clean water and safe buildings to energy and transport.", enHook: "Send to an engineer who sketches solutions on sight"),
    .init(id: "03-08", trDescription: "Dünya Kadınlar Günü, kadınların toplumsal, ekonomik ve siyasi kazanımlarını kutlarken eşitlik için hâlâ gereken değişimi görünür kılar.", trHook: "Eşitlik için alan açan bir kadına gönder", enDescription: "International Women's Day celebrates women's social, economic and political achievements while highlighting the change still needed for equality.", enHook: "Send to a woman who makes room for equality"),
    .init(id: "03-10", trDescription: "Kadınların yargıda eşit temsil edilmesi, adalet kurumlarının toplumun deneyimlerini daha iyi yansıtmasına ve güveni güçlendirmesine yardımcı olur.", trHook: "Adalete emeğini veren bir kadın hukukçuya gönder", enDescription: "Equal representation of women in the judiciary helps justice institutions better reflect society's experience and build trust.", enHook: "Send to a woman who gives her work to justice"),
    .init(id: "03-11", trDescription: "Temiz suyun eve güvenle ulaşması ve atık suyun uzaklaştırılması, görünmeyen ama halk sağlığını her gün koruyan tesisat sistemlerine bağlıdır.", trHook: "Bir sızıntıyı herkesten önce fark eden kişiye gönder", enDescription: "Safe water arriving at home and wastewater leaving it depend on plumbing systems that quietly protect public health every day.", enHook: "Send to the person who spots a leak before anyone else"),
    .init(id: "03-13", trDescription: "Tayland Ulusal Fil Günü, ülkenin kültürüyle güçlü bağları olan Asya fillerini ve yaşam alanlarını koruma ihtiyacına dikkat çeker.", trHook: "Filleri hayranlıkla izleyen biriyle paylaş", enDescription: "Thailand's National Elephant Day highlights Asian elephants, their deep place in Thai culture and the need to protect their habitats.", enHook: "Share with someone who never tires of watching elephants"),
    .init(id: "03-18", trDescription: "Geri dönüşüm tek başına atık sorununu çözmez; daha az tüketmek, yeniden kullanmak ve doğru ayrıştırmakla birlikte anlam kazanır.", trHook: "Atığı azaltmak için somut adım atan biriyle paylaş", enDescription: "Recycling cannot solve waste alone; it works alongside consuming less, reusing more and sorting materials correctly.", enHook: "Share with someone taking practical steps to reduce waste"),
    .init(id: "03-21", trDescription: "Şiir, az kelimeyle geniş bir dünya kurar; bir dilin ritmini, hafızasını ve söylenmesi zor duyguları taşır.", trHook: "Sana bir dizeyle bütün günü değiştiren kişiye gönder", enDescription: "Poetry builds a wide world with few words, carrying a language's rhythm, memory and feelings that are hard to say plainly.", enHook: "Send to someone who can change your day with one line"),
    .init(id: "03-23", trDescription: "Meteoroloji gözlemleri, hava tahmininden iklim takibine kadar yaşamı koruyan kararların temelini oluşturur.", trHook: "Hava durumunu senden önce kontrol eden kişiye gönder", enDescription: "Meteorological observations underpin decisions that protect lives, from everyday forecasting to long-term climate monitoring.", enHook: "Send to someone who checks the forecast before you do"),
    .init(id: "03-27", trDescription: "Tiyatro aynı odada oyuncu ile seyirci arasında bir dünya kurar; her temsil o geceye ve o topluluğa özgü kalır.", trHook: "Perde açıldığında yanında olsun istediğin kişiye gönder", enDescription: "Theatre builds a world between performers and an audience in the same room; every performance belongs uniquely to that night and that crowd.", enHook: "Send to someone you want beside you when the curtain rises"),
    .init(id: "03-28", trDescription: "Çekya ve Slovakya'da Öğretmenler Günü, eğitimi deneyim ve merakla buluşturan düşünür Jan Amos Comenius'un doğum gününde kutlanır.", trHook: "Sana yalnız bilgiyi değil merakı da öğreten kişiye gönder", enDescription: "Teachers' Day in Czechia and Slovakia falls on the birthday of Jan Amos Comenius, who connected education with experience and curiosity.", enHook: "Send to someone who taught you curiosity, not only facts"),
    .init(id: "03-30", trDescription: "Sıfır atık, çöpe daha iyi isim vermek değil; ürünleri ve sistemleri baştan daha az kaynak harcayacak biçimde tasarlamaktır.", trHook: "Tek kullanımlık alışkanlıkları azaltan biriyle paylaş", enDescription: "Zero waste is not a better name for rubbish; it means designing products and systems to use fewer resources from the start.", enHook: "Share with someone reducing single-use habits"),
    .init(id: "04-05", trDescription: "Vicdan, kararlarımızın başkaları üzerindeki etkisini fark etme yetisidir; barış kültürü küçük etik seçimlerle büyür.", trHook: "Doğru olanı sessizken de yapan kişiye gönder", enDescription: "Conscience is the ability to notice how our choices affect others; a culture of peace grows through small ethical decisions.", enHook: "Send to someone who does what is right even in silence"),
    .init(id: "04-06", trDescription: "Spor, doğru kurulduğunda takım çalışmasını, kapsayıcılığı ve çatışma sonrası toplulukların yeniden bağ kurmasını destekleyebilir.", trHook: "Oyunun insanları birleştirdiğine inanan kişiye gönder", enDescription: "When built well, sport can support teamwork, inclusion and renewed connection in communities affected by conflict.", enHook: "Send to someone who believes play can bring people together"),
    .init(id: "04-12", trDescription: "12 Nisan 1961'de Yuri Gagarin uzaya çıkan ilk insan oldu; bu yolculuk insanlı uzay uçuşunda yeni bir çağ açtı.", trHook: "Gökyüzüne bakınca daha fazlasını hayal eden kişiye gönder", enDescription: "On 12 April 1961, Yuri Gagarin became the first human in space, opening a new era of crewed spaceflight.", enHook: "Send to someone who looks up and imagines further"),
    .init(id: "04-15", trDescription: "WhaDay'den küçük bir iyi hissetme molası: bugün seni gerçekten rahatlatan tek şeyi seç ve ona on dakikalık yer aç.", trHook: "Birlikte küçük bir mola vermen gereken kişiye gönder", enDescription: "A small feel-good pause from WhaDay: choose one thing that genuinely settles you and make ten minutes for it today.", enHook: "Send to someone you need to take a small break with"),
    .init(id: "04-16", trDescription: "Ses; nefes, titreşim ve bedenin hassas koordinasyonuyla oluşur. Onu zorlamadan kullanmak ve kalıcı değişiklikte uzmana danışmak önemlidir.", trHook: "Sesini duymayı sevdiğin kişiye gönder", enDescription: "Voice comes from a delicate coordination of breath, vibration and the body. Using it without strain and seeking expert help for lasting change matter.", enHook: "Send to someone whose voice you love hearing"),
    .init(id: "04-18", trDescription: "Anıtlar ve tarihî alanlar yalnız taş değil; toplulukların hafızasını taşıyan, korunması ve anlaşılması gereken ortak mirastır.", trHook: "Birlikte zamanda yolculuk edeceğin kişiye gönder", enDescription: "Monuments and historic sites are more than stone; they carry community memory and form a shared heritage to understand and protect.", enHook: "Send to someone you would travel through time with"),
    .init(id: "04-20", trDescription: "Çince Dil Günü, yazı sisteminin ve farklı Çince çeşitlerinin edebiyat, düşünce ve küresel iletişimdeki zenginliğini kutlar.", trHook: "Yeni bir karakter öğrenmek isteyecek kişiye gönder", enDescription: "Chinese Language Day celebrates the richness of its writing system and language varieties across literature, thought and global communication.", enHook: "Send to someone who would learn a new character today"),
    .init(id: "04-21", trDescription: "Yaratıcılık yeni fikir üretir; yenilikçilik o fikri insanların işine yarayan bir çözüme dönüştürür. İkisi de merakla başlar.", trHook: "Fikri gerçeğe dönüştüren kişiye gönder", enDescription: "Creativity produces a new idea; innovation turns it into a solution people can use. Both begin with curiosity.", enHook: "Send to someone who turns ideas into real things"),
    .init(id: "04-24", trDescription: "Çok taraflı diplomasi, sınır aşan sorunlarda ülkelerin tek başına değil; kurallar, müzakere ve ortak sorumlulukla hareket etmesini sağlar.", trHook: "Diyaloğun gücüne inanan biriyle paylaş", enDescription: "Multilateral diplomacy helps countries address cross-border problems through rules, negotiation and shared responsibility rather than acting alone.", enHook: "Share with someone who believes in the power of dialogue"),
    .init(id: "04-26", trDescription: "Fikri mülkiyet; üreticinin emeğini korumakla bilginin, kültürün ve yeniliğin toplumda dolaşabilmesi arasında denge kurmaya çalışır.", trHook: "Fikirleri kadar emeğe de değer veren kişiye gönder", enDescription: "Intellectual property seeks a balance between protecting creators' work and allowing knowledge, culture and innovation to circulate.", enHook: "Send to someone who values the work behind an idea"),
    .init(id: "04-30", trDescription: "Caz, doğaçlamayı ortak bir dile çevirir; müzisyenler aynı anda hem birbirini dinler hem de yeni bir yol açar.", trHook: "Doğaçlama bir geceye çıkacağın kişiye gönder", enDescription: "Jazz turns improvisation into a shared language: musicians listen to one another while opening a new path in real time.", enHook: "Send to someone you would take to an improvised night out"),
    .init(id: "05-02", trDescription: "Ton balığı milyonlarca insan için gıda ve geçim kaynağıdır; sağlıklı stoklar için bilim temelli ve izlenebilir balıkçılık gerekir.", trHook: "Deniz ürünlerinin nereden geldiğini önemseyen biriyle paylaş", enDescription: "Tuna supports food and livelihoods for millions; healthy stocks depend on science-based, traceable fishing.", enHook: "Share with someone who cares where seafood comes from"),
    .init(id: "05-05", trDescription: "Portekizce farklı kıtalarda yüz milyonlarca insanın dili; müzikten edebiyata çok sesli bir kültür coğrafyasını birbirine bağlar.", trHook: "Sana bir Portekizce şarkı öğretecek kişiye gönder", enDescription: "Portuguese connects hundreds of millions across continents and carries a many-voiced cultural world through music and literature.", enHook: "Send to someone who would teach you a song in Portuguese"),
    .init(id: "05-10", trDescription: "Argan ağacı Fas'ın kurak bölgelerinde toprağı ve geçim kaynaklarını destekler; yağı kadar dayanıklı ekosistemi de değerlidir.", trHook: "Bir ürünün ardındaki ekosistemi merak eden kişiyle paylaş", enDescription: "The argan tree supports soils and livelihoods in Morocco's dry regions; its resilient ecosystem matters as much as its oil.", enHook: "Share with someone curious about the ecosystem behind a product"),
    .init(id: "05-12", trDescription: "Bitki sağlığı; tarımı, ormanları, biyolojik çeşitliliği ve gıda güvenliğini zararlılarla hastalıklardan korumak demektir.", trHook: "Bahçesinde her yaprağı kontrol eden kişiye gönder", enDescription: "Plant health means protecting crops, forests, biodiversity and food security from pests and disease.", enHook: "Send to someone who inspects every leaf in the garden"),
    .init(id: "05-15", trDescription: "Aile tek bir biçime sığmaz; güven, bakım ve aitlik duygusunu birlikte kuran insanların ilişkisiyle anlam kazanır.", trHook: "Ailem dediğin kişiye gönder", enDescription: "Family does not fit one shape; it takes meaning through the people who build trust, care and belonging together.", enHook: "Send to someone you call family"),
    .init(id: "05-16", trDescription: "Işık bilimi; tıptan iletişime, enerjiden sanata kadar modern yaşamın görünür ve görünmez altyapısını kurar.", trHook: "Dünyaya başka bir ışıkta bakan kişiye gönder", enDescription: "The science of light forms visible and invisible infrastructure across medicine, communication, energy and art.", enHook: "Send to someone who sees the world in another light"),
    .init(id: "05-17", trDescription: "Telekomünikasyon ağları insanları ve bilgiyi saniyeler içinde buluşturuyor; anlamlı erişim ise bağlantının güvenli, uygun fiyatlı ve kapsayıcı olmasını gerektiriyor.", trHook: "Mesafe ne olursa olsun ulaştığın kişiye gönder", enDescription: "Telecommunication networks connect people and information in seconds; meaningful access also needs to be safe, affordable and inclusive.", enHook: "Send to someone you can reach across any distance"),
    .init(id: "05-18", trDescription: "Müzeler nesne toplamaktan fazlasını yapar; hafızayı korur, farklı anlatıları yan yana getirir ve merak için kamusal alan açar.", trHook: "Birlikte bütün günü müzede geçireceğin kişiye gönder", enDescription: "Museums do more than collect objects; they protect memory, place different stories side by side and make public room for curiosity.", enHook: "Send to someone you would spend an entire museum day with"),
    .init(id: "05-19", trDescription: "Fair play yalnız kurallara uymak değil; rakibe, hakeme ve oyunun ortak emeğine saygı göstermek demektir.", trHook: "Kaybederken de centilmen kalan kişiye gönder", enDescription: "Fair play means more than following rules; it is respect for opponents, officials and the shared work that makes play possible.", enHook: "Send to someone who stays gracious even in defeat"),
    .init(id: "05-22", trDescription: "Biyolojik çeşitlilik; gıdayı, suyu, sağlığı ve iklim direncini destekleyen canlı ağdır. Bir türün kaybı bütün sistemi etkileyebilir.", trHook: "Yaşamın çeşitliliğini koruyan biriyle paylaş", enDescription: "Biodiversity is the living network supporting food, water, health and climate resilience. Losing one species can affect the whole system.", enHook: "Share with someone who protects life's diversity"),
    .init(id: "05-24", trDescription: "Markhor, Orta ve Güney Asya'nın dağlık bölgelerinde yaşayan yabani bir keçidir; korunması hem yaşam alanını hem yerel toplulukları destekler.", trHook: "Dağların en etkileyici sakinini keşfedecek kişiye gönder", enDescription: "The markhor is a wild goat of Central and South Asian mountains; protecting it supports both habitat and local communities.", enHook: "Send to someone ready to meet the mountains' most impressive resident"),
    .init(id: "05-25", trDescription: "Futbol basit bir topu mahalle arasından dev stadyumlara taşıyan ortak dil; oyuna erişim ve güvenli alanlar herkes için önemli.", trHook: "Maçın skorundan çok beraberliğini sevdiğin kişiye gönder", enDescription: "Football is a shared language carrying one simple ball from neighbourhood streets to vast stadiums; access and safe play matter for everyone.", enHook: "Send to someone whose company matters more than the score"),
    .init(id: "05-27", trDescription: "İç barış bütün sorunların bitmesi değil; belirsizliğin içinde bile kendi sesini duyabileceğin biraz alan bulmaktır.", trHook: "Yanında sessizliğin bile iyi geldiği kişiye gönder", enDescription: "Inner peace is not the end of every problem; it is finding enough room to hear your own voice inside uncertainty.", enHook: "Send to someone whose silence feels good beside yours"),
    .init(id: "05-29", trDescription: "BM barış gücü personeli, çatışma ortamlarında sivilleri koruma ve barış süreçlerini destekleme görevlerinde ciddi riskler üstlenir.", trHook: "Hizmette hayatını kaybedenleri saygıyla an", enDescription: "UN peacekeeping personnel take serious risks while protecting civilians and supporting peace processes in conflict settings.", enHook: "Remember those who lost their lives in service with care"),
    .init(id: "05-30", trDescription: "Patates binlerce çeşidi, farklı iklimlere uyumu ve besleyici değeriyle dünya gıda sisteminde küçük görünenden çok daha büyük yer tutar.", trHook: "Patatesin her hâline evet diyen kişiye gönder", enDescription: "With thousands of varieties, climate adaptability and nutritional value, the potato holds a much larger place in world food systems than it appears.", enHook: "Send to someone who says yes to potatoes in every form"),
    .init(id: "06-01", trDescription: "Ebeveynlik bakım, zaman ve görünmeyen emek ister; ailelerin bu sorumluluğu güvenli hizmetler ve toplumsal destekle paylaşabilmesi gerekir.", trHook: "Emeğini gördüğün bir ebeveyne gönder", enDescription: "Parenting takes care, time and invisible work; families need safe services and social support to carry that responsibility.", enHook: "Send to a parent whose work you see"),
    .init(id: "06-03", trDescription: "Bisiklet ulaşım, hareket ve özgürlük hissini iki tekerde birleştirir; güvenli yollar ve erişilebilir kentler sürüşü herkes için mümkün kılar.", trHook: "Birlikte uzun bir rota çevireceğin kişiye gönder", enDescription: "The bicycle combines transport, movement and freedom on two wheels; safe routes and accessible cities make riding possible for more people.", enHook: "Send to someone you would ride a long route with"),
    .init(id: "06-06", trDescription: "Rusça Dil Günü, Aleksandr Puşkin'in doğum gününde Rusçanın edebiyat, bilim ve uluslararası iletişimdeki mirasını kutlar.", trHook: "Sana yeni bir Rusça kelime öğretecek kişiye gönder", enDescription: "Russian Language Day falls on Alexander Pushkin's birthday and celebrates Russian across literature, science and international communication.", enHook: "Send to someone who would teach you a new Russian word"),
    .init(id: "06-07", trDescription: "Gıda güvenliği tarladan mutfağa uzanan ortak zincirdir; temiz hazırlık, doğru saklama ve güvenilir denetim gıda kaynaklı hastalıkları azaltır.", trHook: "Mutfakta hijyeni asla şansa bırakmayan kişiye gönder", enDescription: "Food safety is a shared chain from farm to kitchen; clean preparation, correct storage and reliable oversight reduce foodborne illness.", enHook: "Send to someone who never leaves kitchen hygiene to chance"),
    .init(id: "06-10", trDescription: "Medeniyetler arası diyalog, kültürleri tek tipe çevirmek değil; farklı tarihlerin ve dünya görüşlerinin birbirini dinleyebileceği alan kurmaktır.", trHook: "Merakla dinlemeyi bilen birine gönder", enDescription: "Dialogue among civilizations does not flatten cultures; it creates space for different histories and worldviews to listen to one another.", enHook: "Send to someone who knows how to listen with curiosity"),
    .init(id: "06-11", trDescription: "Oyun çocukların öğrenme, ilişki kurma ve hayal gücünü geliştirme yollarından biridir; güvenli oyun alanı bir lüks değil ihtiyaçtır.", trHook: "İçindeki çocuğu oyuna çağıracağın kişiye gönder", enDescription: "Play helps children learn, connect and develop imagination; safe space to play is a need, not a luxury.", enHook: "Send to someone whose inner child you would invite out to play"),
    .init(id: "06-16", trDescription: "Aile havaleleri, göçmenlerin kazançlarından evdeki yakınlarına gönderdiği ve eğitimden sağlığa gündelik yaşamı destekleyen kaynaklardır.", trHook: "Mesafeyi emeğiyle kapatan aileleri düşünerek paylaş", enDescription: "Family remittances are earnings migrants send to loved ones at home, supporting daily needs from education to health.", enHook: "Share with families whose work bridges distance in mind"),
    .init(id: "06-24", trDescription: "Diplomaside kadınların eşit temsili, barış ve dış politika kararlarına daha geniş deneyimlerin ve önceliklerin katılmasını sağlar.", trHook: "Masada yer açan bir kadın lidere gönder", enDescription: "Equal representation of women in diplomacy brings a wider range of experience and priorities into decisions on peace and foreign policy.", enHook: "Send to a woman leader who makes room at the table"),
    .init(id: "06-25", trDescription: "Denizciler küresel ticaretin büyük bölümünü görünmeden taşır; güvenli çalışma, dinlenme ve bağlantı hakları denizde de geçerlidir.", trHook: "Ufkun ötesinde çalışan bir denizciye gönder", enDescription: "Seafarers carry much of global trade out of sight; rights to safe work, rest and connection still apply at sea.", enHook: "Send to a seafarer working beyond the horizon"),
    .init(id: "06-27", trDescription: "Mikro, küçük ve orta işletmeler yerel istihdamın ve gündelik ekonominin omurgasıdır; finansmana ve dijital araçlara erişim büyümelerini belirler.", trHook: "Emeğiyle kendi işini büyüten kişiye gönder", enDescription: "Micro, small and medium enterprises are a backbone of local jobs and daily economies; access to finance and digital tools shapes their growth.", enHook: "Send to someone building a business through their own work"),
    .init(id: "06-29", trDescription: "Tropikal bölgeler olağanüstü biyolojik ve kültürel çeşitlilik taşırken iklim değişikliği, eşitsizlik ve hızlı kentleşmenin baskısıyla karşı karşıya.", trHook: "Tropiklerin yalnız tatil fotoğrafı olmadığını bilen biriyle paylaş", enDescription: "The tropics hold extraordinary biological and cultural diversity while facing pressure from climate change, inequality and rapid urbanization.", enHook: "Share with someone who knows the tropics are more than a holiday image"),
    .init(id: "06-30", trDescription: "Asteroitleri izlemek, Güneş Sistemi'nin geçmişini anlamaya ve Dünya'ya yaklaşabilecek cisimler için erken hazırlık yapmaya yardımcı olur.", trHook: "Gökyüzündeki taşları bile merak eden kişiye gönder", enDescription: "Tracking asteroids helps explain the Solar System's past and supports early preparation for objects that may approach Earth.", enHook: "Send to someone curious even about rocks in the sky")
]

private let nonOfficialSources: [String: SourcePatch] = [
    "01-30": .init(organization: "DENIP", url: "https://denip.webnode.es/"),
    "02-03": .init(organization: "US Army", url: "https://www.army.mil/article/199164/four_chaplains_day"),
    "02-22": .init(organization: "World Association of Girl Guides and Girl Scouts", url: "https://www.wagggs.org/en/what-we-do/world-thinking-day/"),
    "02-27": .init(organization: "World NGO Day", url: "https://worldngoday.org/"),
    "02-28": .init(organization: "Government of India", url: "https://dst.gov.in/national-science-day"),
    "03-11": .init(organization: "World Plumbing Council", url: "https://www.worldplumbing.org/worldplumbingday/"),
    "03-13": .init(organization: "Thailand Department of National Parks", url: "https://www.dnp.go.th/"),
    "03-18": .init(organization: "Global Recycling Foundation", url: "https://www.globalrecyclingday.com/"),
    "03-27": .init(organization: "International Theatre Institute", url: "https://www.iti-worldwide.org/worldtheatreday.php"),
    "03-28": .init(organization: "Czech Ministry of Education", url: "https://msmt.gov.cz/"),
    "04-16": .init(organization: "World Voice Day", url: "https://worldvoiceday.org/"),
    "04-18": .init(organization: "ICOMOS", url: "https://www.icomos.org/18th-april-international-day-for-monuments-and-sites"),
    "05-18": .init(organization: "International Council of Museums", url: "https://imd.icom.museum/")
]

private let editorialIDs: Set<String> = ["04-15", "05-27"]
private let nonOfficialIDs = Set(nonOfficialSources.keys)
private let targetIDs = Set(copy.map(\.id))
private let officialIDs = targetIDs.subtracting(nonOfficialIDs).subtracting(editorialIDs)
private let remembranceIDs: Set<String> = ["02-03"]
private let considerateIDs: Set<String> = ["05-29"]
private let relationshipIDs: Set<String> = ["02-22", "05-15", "05-27", "06-01", "06-11", "06-16"]
private let natureIDs: Set<String> = ["01-26", "02-02", "03-03", "03-13", "03-18", "03-30", "05-02", "05-10", "05-12", "05-22", "05-24", "06-29"]
private let cultureIDs: Set<String> = ["03-21", "03-27", "04-18", "04-20", "04-30", "05-05", "05-18", "06-06"]
private let scienceIDs: Set<String> = ["02-28", "03-04", "03-23", "04-12", "04-16", "04-21", "04-26", "05-16", "06-30"]
private let sportIDs: Set<String> = ["04-06", "05-19", "05-25", "06-03", "06-11"]
private let foodIDs: Set<String> = ["02-10", "05-02", "05-30", "06-07"]
private let professionIDs: Set<String> = ["03-10", "03-11", "05-29", "06-25", "06-27"]

guard copy.count == 60, targetIDs.count == copy.count else {
    fatalError("Expected 60 unique H1 records")
}

private let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
private let unMaster = SourcePatch(organization: "United Nations", url: "https://www.un.org/en/observances/list-days-weeks")

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

private func category(for id: String) -> String {
    if remembranceIDs.contains(id) { return "remembrance" }
    if relationshipIDs.contains(id) { return "relationships" }
    if natureIDs.contains(id) { return "animals-and-nature" }
    if cultureIDs.contains(id) { return "culture-and-arts" }
    if scienceIDs.contains(id) { return "science-and-curiosity" }
    if sportIDs.contains(id) { return "sport-and-movement" }
    if foodIDs.contains(id) { return "food-and-drink" }
    if professionIDs.contains(id) { return "professions" }
    if editorialIDs.contains(id) { return "playful" }
    return "civil-society"
}

private func curateLocalized(_ language: String) throws {
    let url = root.appendingPathComponent("WhaDayNative/Data/\(language).json")
    var days = try JSONDecoder().decode([LocalizedDay].self, from: Data(contentsOf: url))
    let byID = Dictionary(uniqueKeysWithValues: copy.map { ($0.id, $0) })
    guard days.count == 366, targetIDs.isSubset(of: Set(days.map(\.id))) else {
        fatalError("\(language) corpus is missing H1 records")
    }
    for index in days.indices {
        guard let patch = byID[days[index].id] else { continue }
        days[index].description = language == "tr" ? patch.trDescription : patch.enDescription
        days[index].sharingHook = language == "tr" ? patch.trHook : patch.enHook
        if days[index].id == "04-15" {
            days[index].title = language == "tr" ? "İyi Hissetme Molası" : "Feel-Good Pause"
            days[index].emoji = "🌤️"
            days[index].category = "social"
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
        records[index]["category"] = category(for: id)
        records[index]["sensitivity"] = remembranceIDs.contains(id) ? "remembrance" : (considerateIDs.contains(id) ? "considerate" : "standard")
        records[index]["shareability"] = remembranceIDs.contains(id) ? 1 : (considerateIDs.contains(id) ? 2 : (relationshipIDs.contains(id) || editorialIDs.contains(id) ? 5 : 4))
        records[index]["audience"] = remembranceIDs.contains(id) || considerateIDs.contains(id) ? ["careful-sharing"] : (relationshipIDs.contains(id) || editorialIDs.contains(id) ? ["friend", "community"] : ["community"])
        records[index]["scope"] = editorialIDs.contains(id) ? "whaday-editorial" : "international"
        if officialIDs.contains(id) {
            records[index]["authority"] = "official"
            records[index]["source"] = ["organization": unMaster.organization, "url": unMaster.url, "checkedAt": "2026-08-14"]
        } else if let source = nonOfficialSources[id] {
            records[index]["authority"] = "cultural"
            records[index]["source"] = ["organization": source.organization, "url": source.url, "checkedAt": "2026-08-14"]
        } else {
            records[index]["authority"] = "editorial"
            records[index].removeValue(forKey: "source")
        }
        if id == "04-15" { records[index]["symbol"] = "🌤️" }
        updated += 1
    }
    guard updated == 60 else { fatalError("Expected 60 metadata updates, wrote \(updated)") }
    let output = try JSONSerialization.data(withJSONObject: records, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    try output.write(to: url, options: .atomic)
}

try curateLocalized("tr")
try curateLocalized("en")
try curateMetadata()
print("Curated 60 January-June institutional records")
