#!/usr/bin/env swift

import Foundation

// Editorial review for the remaining July-December institutional records.

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
    .init(id: "07-03", trDescription: "Plastik poşetin birkaç dakikalık kolaylığı, doğada yıllarca kalan atığa dönüşebilir. Yeniden kullanılabilir çanta küçük ama tekrarlanan bir seçimdir.", trHook: "Çantasında her zaman bez çanta taşıyan kişiye gönder", enDescription: "A plastic bag's few minutes of convenience can become waste that remains for years. A reusable bag is a small choice made repeatedly.", enHook: "Send to someone who always carries a reusable bag"),
    .init(id: "07-06", trDescription: "Kırsal kalkınma; tarımın ötesinde sağlık, eğitim, bağlantı, güvenli altyapı ve yerel karar gücüne eşit erişim demektir.", trHook: "Kırsal yaşamın geleceğini önemseyen biriyle paylaş", enDescription: "Rural development reaches beyond agriculture to equal access to health, education, connectivity, safe infrastructure and local decision-making.", enHook: "Share with someone who cares about the future of rural life"),
    .init(id: "07-07", trDescription: "Kiswahili, Doğu ve Orta Afrika'da milyonları birbirine bağlayan ve Afrika Birliği'nin çalışma dilleri arasında yer alan güçlü bir ortak dildir.", trHook: "Sana 'habari' diye selam verecek kişiye gönder", enDescription: "Kiswahili is a powerful shared language connecting millions across East and Central Africa and serving as a working language of the African Union.", enHook: "Send to someone who would greet you with 'habari'"),
    .init(id: "07-10", trDescription: "Nikola Tesla'nın doğum günü, alternatif akım sistemlerinden kablosuz iletişim fikirlerine uzanan bilimsel hayal gücünü hatırlatır.", trHook: "Aklı sürekli gelecekte çalışan kişiye gönder", enDescription: "Nikola Tesla's birthday recalls a scientific imagination that ranged from alternating-current systems to ideas for wireless communication.", enHook: "Send to someone whose mind permanently lives in the future"),
    .init(id: "07-11", trDescription: "Dünya Nüfus Günü, nüfus sayılarını değil; üreme sağlığına, eğitime, fırsata ve kendi yaşamı hakkında karar verme hakkına eşit erişimi merkeze alır.", trHook: "Hakları ve insan onurunu merkeze alarak paylaş", enDescription: "World Population Day centers not population numbers but equal access to reproductive health, education, opportunity and decisions about one's own life.", enHook: "Share with rights and human dignity at the center"),
    .init(id: "07-12", trDescription: "Kum ve toz fırtınaları sağlığı, tarımı ve ulaşımı sınırlar ötesinde etkiler; erken uyarı ve arazi yönetimi ortak hazırlığın parçalarıdır.", trHook: "İklim risklerini doğrulanmış bilgiyle paylaş", enDescription: "Sand and dust storms affect health, farming and transport across borders; early warning and land management are parts of shared preparedness.", enHook: "Share climate risks with verified information"),
    .init(id: "07-20", trDescription: "20 Temmuz 1969'da Apollo 11 Ay'a indi; Uluslararası Ay Günü, bu adımı ve Ay araştırmalarının ortak geleceğini hatırlatır.", trHook: "Ay'a bakınca hâlâ heyecanlanan kişiye gönder", enDescription: "Apollo 11 landed on the Moon on 20 July 1969; International Moon Day marks that step and the shared future of lunar exploration.", enHook: "Send to someone still thrilled by looking at the Moon"),
    .init(id: "07-24", trDescription: "24 Temmuz, Güney Amerika'nın bağımsızlık mücadelelerinde belirleyici rol oynayan Simón Bolívar'ın doğum günüdür; mirası bölgede farklı biçimlerde yorumlanır.", trHook: "Latin Amerika tarihine meraklı biriyle paylaş", enDescription: "24 July is the birthday of Simón Bolívar, a central figure in South American independence whose legacy is interpreted in different ways across the region.", enHook: "Share with someone curious about Latin American history"),
    .init(id: "07-29", trDescription: "Kaplanlar sağlıklı orman ekosistemlerinin göstergeleridir; yaşam alanı kaybı ve yasa dışı ticaret, vahşi popülasyonları tehdit etmeyi sürdürüyor.", trHook: "Kaplanları yalnız ekranda değil doğada da görmek isteyen kişiye gönder", enDescription: "Tigers are indicators of healthy forest ecosystems; habitat loss and illegal trade continue to threaten wild populations.", enHook: "Send to someone who wants tigers to remain wild, not only on screens"),
    .init(id: "08-06", trDescription: "Denize kıyısı olmayan gelişmekte olan ülkeler, küresel pazarlara ulaşırken daha uzun ve maliyetli taşıma yollarıyla karşılaşır; bağlantı ve adil ticaret kritik önemdedir.", trHook: "Coğrafyanın fırsatı belirlememesi gerektiğini düşünen biriyle paylaş", enDescription: "Landlocked developing countries face longer, costlier routes to global markets; connectivity and fair trade are essential to closing that gap.", enHook: "Share with someone who believes geography should not decide opportunity"),
    .init(id: "08-10", trDescription: "Aslanlar yaşam alanı kaybı, insan-yaban hayatı çatışması ve kaçak avcılık baskısıyla karşı karşıya; koruma yerel topluluklarla birlikte yürüdüğünde güçlenir.", trHook: "Aslanların sesinin doğada kalmasını isteyen kişiye gönder", enDescription: "Lions face habitat loss, human-wildlife conflict and poaching pressure; conservation grows stronger when it works with local communities.", enHook: "Send to someone who wants the lion's roar to remain in the wild"),
    .init(id: "08-11", trDescription: "Trinidad ve Tobago'da doğan steelpan, petrol varillerinden akort edilen yüzeylerle kurulan ve bugün dünya sahnelerinde duyulan özgün bir çalgıdır.", trHook: "Ritmi duyunca yerinde duramayan kişiye gönder", enDescription: "Born in Trinidad and Tobago, the steelpan turns tuned metal surfaces into a distinctive instrument now heard on stages around the world.", enHook: "Send to someone who cannot stand still once the rhythm starts"),
    .init(id: "08-20", trDescription: "Dünya Sivrisinek Günü, Ronald Ross'un 1897'de sivrisineklerin sıtma bulaşındaki rolünü gösteren keşfini anar; vektör kontrolü hâlâ hayat kurtarır.", trHook: "Sivrisinekleri yalnız sinir bozucu sanan kişiye gönder", enDescription: "World Mosquito Day marks Ronald Ross's 1897 discovery of mosquitoes' role in malaria transmission; vector control still saves lives.", enHook: "Send to someone who thinks mosquitoes are only annoying"),
    .init(id: "08-27", trDescription: "Göller içme suyu, canlı yaşamı, iklim dengesi ve yerel geçim için önemlidir; kirlilik ve aşırı kullanım kıyının çok ötesini etkiler.", trHook: "En güzel göl anını paylaştığın kişiye gönder", enDescription: "Lakes support drinking water, wildlife, climate balance and local livelihoods; pollution and overuse affect far more than the shoreline.", enHook: "Send to someone who shares your best lake memory"),
    .init(id: "09-01", trDescription: "Bilgi Günü, Rusya ve bazı eski Sovyet ülkelerinde yeni eğitim yılının başlangıcını; çiçekler, ilk dersler ve okul törenleriyle işaretler.", trHook: "İlk okul gününü hâlâ hatırlayan kişiye gönder", enDescription: "Knowledge Day marks the start of the school year in Russia and some former Soviet countries with flowers, first lessons and school ceremonies.", enHook: "Send to someone who still remembers their first day of school"),
    .init(id: "09-04", trDescription: "ABD merkezli Ulusal Yaban Hayatı Günü, yerel türleri ve onları koruyan barınaklarla kuruluşların emeğini görünür kılan bir farkındalık günüdür.", trHook: "Yaşadığı yerdeki yaban hayatını tanıyan kişiye gönder", enDescription: "US-based National Wildlife Day highlights local species and the work of sanctuaries and organizations that protect them.", enHook: "Send to someone who knows the wildlife where they live"),
    .init(id: "09-05", trDescription: "Hayırseverlik yalnız bağış miktarı değil; ihtiyacı dinlemek, güvenilir bir yapıyı desteklemek ve dayanışmayı süreklileştirmektir.", trHook: "İyiliği gösterişsizce çoğaltan kişiye gönder", enDescription: "Charity is not only an amount donated; it means listening to need, supporting trustworthy work and making solidarity last.", enHook: "Send to someone who grows good quietly"),
    .init(id: "09-07", trDescription: "Temiz hava sağlığın temelidir; ulaşım, enerji ve kent politikalarında kirleticileri azaltmak mavi gökyüzünü herkes için mümkün kılar.", trHook: "Daha temiz bir şehir isteyen biriyle paylaş", enDescription: "Clean air is fundamental to health; reducing pollutants across transport, energy and city policy makes blue skies possible for everyone.", enHook: "Share with someone who wants a cleaner city"),
    .init(id: "09-08", trDescription: "Okuryazarlık yalnız harfleri çözmek değil; bilgiye ulaşmak, hakları kullanmak ve kendi hikâyesini anlatabilmek için temel bir güçtür.", trHook: "Sana okuma sevgisi kazandıran kişiye gönder", enDescription: "Literacy is more than decoding letters; it is a foundation for reaching information, using rights and telling one's own story.", enHook: "Send to the person who gave you a love of reading"),
    .init(id: "09-14", trDescription: "Haçın Yüceltilmesi Bayramı, Hristiyan geleneklerinde haçın inançtaki anlamını anan ve farklı kiliselerde ibadetle kutlanan dinî bir gündür.", trHook: "Yalnız ilgili inanç bağlamında saygıyla paylaş", enDescription: "The Exaltation of the Holy Cross is a Christian feast reflecting on the cross's meaning in faith and observed in worship across several churches.", enHook: "Share respectfully and only in the relevant faith context"),
    .init(id: "09-15", trDescription: "Demokrasi yalnız seçim günü değil; ifade özgürlüğü, katılım, çoğulculuk, hukukun üstünlüğü ve kurumların hesap verebilirliğiyle her gün kurulur.", trHook: "Söz hakkının herkes için olduğuna inanan biriyle paylaş", enDescription: "Democracy is more than election day; it is built daily through expression, participation, pluralism, rule of law and accountable institutions.", enHook: "Share with someone who believes everyone deserves a voice"),
    .init(id: "09-16", trDescription: "Ozon tabakası zararlı morötesi ışınların büyük bölümünü süzer; onu incelten maddelerin azaltılması küresel iş birliğinin somut başarılarından biridir.", trHook: "Bilimin dünyayı gerçekten değiştirebildiğine inanan kişiye gönder", enDescription: "The ozone layer filters much harmful ultraviolet radiation; reducing ozone-depleting substances is a practical success of global cooperation.", enHook: "Send to someone who believes science can truly change the world"),
    .init(id: "09-20", trDescription: "Dünya Temizlik Günü, atığı toplamanın yanında nereden geldiğini görmeyi ve tekrar oluşmasını önleyecek sistemleri talep etmeyi de gerektirir.", trHook: "Mahallesini daha temiz bırakan biriyle paylaş", enDescription: "World Cleanup Day is not only about collecting waste; it also means seeing where it came from and demanding systems that prevent it.", enHook: "Share with someone who leaves their neighbourhood cleaner"),
    .init(id: "09-22", trDescription: "Arabasız bir gün; yürünebilir sokakların, güvenli bisiklet yollarının ve güçlü toplu taşımanın kent yaşamını nasıl değiştirebileceğini gösterir.", trHook: "Şehri yürüyerek keşfedeceğin kişiye gönder", enDescription: "A car-free day shows how walkable streets, safe cycle routes and strong public transport can change city life.", enHook: "Send to someone you would explore the city on foot with"),
    .init(id: "09-23", trDescription: "İşaret dilleri tam ve doğal dillerdir; sağır toplulukların kültürünü, eğitimini ve kamusal yaşama eşit katılımını taşır.", trHook: "Erişilebilir iletişimi önemseyen biriyle paylaş", enDescription: "Sign languages are complete natural languages carrying Deaf culture, education and equal participation in public life.", enHook: "Share with someone who cares about accessible communication"),
    .init(id: "09-25", trDescription: "Eczacılar ilaçların güvenli ve doğru kullanımında, aşılama ve sağlık danışmanlığında insanların en erişilebilir uzmanları arasında yer alır.", trHook: "Sorusunu sabırla yanıtlayan bir eczacıya gönder", enDescription: "Pharmacists are among the most accessible health professionals for safe medicine use, vaccination and health guidance.", enHook: "Send to a pharmacist who answers every question patiently"),
    .init(id: "09-27", trDescription: "Turizm doğru yönetildiğinde yerel geçimi ve kültürel alışverişi destekler; aşırı yük ve kaynak baskısı ise topluluklarla birlikte yönetilmelidir.", trHook: "Gezdiği yere misafir gibi davranan kişiye gönder", enDescription: "When managed well, tourism supports local livelihoods and cultural exchange; crowding and resource pressure must be addressed with communities.", enHook: "Send to someone who behaves like a guest wherever they travel"),
    .init(id: "09-28", trDescription: "Bilgiye erişim, insanların haklarını kullanabilmesi, kamu kararlarını anlayabilmesi ve kurumları denetleyebilmesi için temel önemdedir.", trHook: "Şeffaflığın herkesin hakkı olduğunu düşünen biriyle paylaş", enDescription: "Access to information is essential for people to use their rights, understand public decisions and hold institutions accountable.", enHook: "Share with someone who believes transparency belongs to everyone"),
    .init(id: "09-29", trDescription: "Üretilen gıdanın kaybolması ya da çöpe gitmesi; suyu, toprağı, emeği ve enerjiyi de boşa harcar. Planlama ve doğru saklama fark yaratır.", trHook: "Buzdolabındaki son malzemeyi bile değerlendiren kişiye gönder", enDescription: "When food is lost or wasted, water, soil, labour and energy are wasted with it. Planning and correct storage make a difference.", enHook: "Send to someone who uses even the last ingredient in the fridge"),
    .init(id: "09-30", trDescription: "Çevirmenler yalnız kelimeleri değil; niyeti, tonu ve kültürel bağlamı diller arasında taşır.", trHook: "İki dil arasında köprü kuran kişiye gönder", enDescription: "Translators carry more than words between languages; they carry intention, tone and cultural context.", enHook: "Send to someone who builds bridges between languages"),
    .init(id: "10-04", trDescription: "4-10 Ekim Dünya Uzay Haftası, Sputnik 1'in fırlatılması ile Uzay Antlaşması'nın yürürlüğe girdiği tarihleri birbirine bağlar.", trHook: "Bir hafta boyunca gökyüzü konuşacağın kişiye gönder", enDescription: "World Space Week, 4-10 October, connects the launch of Sputnik 1 with the date the Outer Space Treaty entered into force.", enHook: "Send to someone you could talk space with for a week"),
    .init(id: "10-05", trDescription: "Öğretmenler yalnız ders anlatmaz; merakı korur, güvenli bir sınıf kurar ve bir öğrencinin kendine bakışını değiştirebilir.", trHook: "Hayatının yönünü değiştiren öğretmene gönder", enDescription: "Teachers do more than deliver lessons; they protect curiosity, build safe classrooms and can change how a learner sees themselves.", enHook: "Send to the teacher who changed your direction"),
    .init(id: "10-07", trDescription: "Pamuk milyonlarca insanın geçim kaynağı ve küresel tekstilin temel liflerinden biri; su, emek ve izlenebilir üretim koşulları önem taşıyor.", trHook: "Giydiğinin nasıl üretildiğini merak eden biriyle paylaş", enDescription: "Cotton supports millions of livelihoods and much of global textiles; water, labour and traceable production conditions matter.", enHook: "Share with someone curious about how their clothes are made"),
    .init(id: "10-09", trDescription: "Posta ağları yüzyıllardır insanları, belgeleri ve ticareti birbirine bağlıyor; bugün fiziksel ve dijital hizmetleri birlikte taşıyor.", trHook: "Hâlâ el yazısı mektup göndereceğin kişiye gönder", enDescription: "Postal networks have connected people, documents and trade for centuries and now carry physical and digital services together.", enHook: "Send to someone you would still write a letter by hand to"),
    .init(id: "10-14", trDescription: "Standartlar görünmez ortak dil gibidir; cihazların birlikte çalışmasını, ölçümlerin tutmasını ve ürünlerin daha güvenli olmasını sağlar.", trHook: "Her şeyi ölçüp düzenleyen kişiye gönder", enDescription: "Standards act like an invisible shared language, helping devices work together, measurements agree and products become safer.", enHook: "Send to someone who measures and organizes everything"),
    .init(id: "10-23", trDescription: "Kar leoparları Orta ve Güney Asya'nın yüksek dağlarında yaşar; yaşam alanlarını korumak su kaynaklarını ve dağ topluluklarını da destekler.", trHook: "Dağların hayaletini keşfetmek isteyecek kişiye gönder", enDescription: "Snow leopards live across the high mountains of Central and South Asia; protecting their habitat also supports water sources and mountain communities.", enHook: "Send to someone who would love to meet the ghost of the mountains"),
    .init(id: "10-27", trDescription: "Film, ses kaydı ve yayın arşivleri kolayca bozulabilen taşıyıcılarda toplumsal hafızayı saklar; korunmaları geleceğin geçmişi duyabilmesini sağlar.", trHook: "Eski kayıtların peşine düşen kişiye gönder", enDescription: "Film, sound and broadcast archives hold public memory on fragile formats; preserving them lets the future hear the past.", enHook: "Send to someone who loves searching through old recordings"),
    .init(id: "10-28", trDescription: "Animasyon çizgi, kukla, kil ya da pikseli hareket yanılsamasına dönüştürür; imkânsız görünen dünyalara zaman ve karakter verir.", trHook: "Birlikte animasyon maratonu yapacağın kişiye gönder", enDescription: "Animation turns drawings, puppets, clay or pixels into the illusion of movement, giving time and character to impossible worlds.", enHook: "Send to someone you would have an animation marathon with"),
    .init(id: "10-29", trDescription: "Bakım emeği çocuklardan yaşlılara, engelli bireylerden hastalara kadar yaşamı sürdürür; tanınması, paylaşılması ve desteklenmesi gerekir.", trHook: "Görünmeyen bakım emeğini üstlenen kişiye gönder", enDescription: "Care work sustains life for children, older people, disabled people and those who are ill; it must be recognized, shared and supported.", enHook: "Send to someone carrying care work that often goes unseen"),
    .init(id: "11-01", trDescription: "Tüm Azizler Günü, birçok Hristiyan geleneğinde bilinen ve bilinmeyen azizleri anmak için ibadet ve ziyaretlerle geçirilen dinî bir gündür.", trHook: "Yalnız ilgili inanç bağlamında saygıyla paylaş", enDescription: "All Saints' Day is a Christian observance honoring known and unknown saints through worship and remembrance in many traditions.", enHook: "Share respectfully and only in the relevant faith context"),
    .init(id: "11-07", trDescription: "Uluslararası İnuit Günü, İnuit kültürünü, dillerini ve haklarını kendi topluluklarının sesleriyle görünür kılar.", trHook: "İnuitlerin kendi seslerini merkeze alarak paylaş", enDescription: "International Inuit Day highlights Inuit culture, languages and rights through the voices of Inuit communities themselves.", enHook: "Share by centering Inuit voices"),
    .init(id: "11-08", trDescription: "Şehircilik, binaların ötesinde insanların konuta, ulaşıma, yeşil alana ve kamusal yaşama nasıl eriştiğini birlikte tasarlar.", trHook: "Daha yaşanabilir sokaklar hayal eden kişiye gönder", enDescription: "Town planning reaches beyond buildings to shape access to housing, transport, green space and public life.", enHook: "Send to someone who imagines more livable streets"),
    .init(id: "11-09", trDescription: "ABD'de ilan edilen Dünya Özgürlük Günü, 9 Kasım 1989'da Berlin Duvarı'nın açılmasını ve Doğu Avrupa'daki demokratik dönüşümü anar.", trHook: "Tarihsel ve ülkeye özgü bağlamıyla paylaş", enDescription: "Observed in the United States, World Freedom Day marks the opening of the Berlin Wall on 9 November 1989 and democratic change in Eastern Europe.", enHook: "Share with its historical and country-specific context"),
    .init(id: "11-10", trDescription: "Bilim toplumdan kopuk değildir; barış ve sürdürülebilir kalkınma için açık bilgiye, etik sorumluluğa ve halkla diyaloğa ihtiyaç duyar.", trHook: "Bilimi herkes için anlaşılır kılan kişiye gönder", enDescription: "Science is not separate from society; peace and sustainable development need open knowledge, ethical responsibility and public dialogue.", enHook: "Send to someone who makes science understandable to everyone"),
    .init(id: "11-16", trDescription: "Hoşgörü ilgisizlik değil; farklı hak ve kimliklerin eşitliğini kabul edip ayrımcılığa karşı durma sorumluluğudur.", trHook: "Farklılıkları gerçekten dinleyen kişiye gönder", enDescription: "Tolerance is not indifference; it is recognizing equal rights across differences and taking responsibility against discrimination.", enHook: "Send to someone who genuinely listens across differences"),
    .init(id: "11-20", trDescription: "Dünya Çocuk Günü, Çocuk Hakları Sözleşmesi'nin kabul edildiği tarihte her çocuğun güvenlik, eğitim, sağlık, oyun ve söz hakkını hatırlatır.", trHook: "Çocukların sesine gerçekten yer açan kişiye gönder", enDescription: "World Children's Day marks the adoption date of the Convention on the Rights of the Child and every child's rights to safety, education, health, play and a voice.", enHook: "Send to someone who genuinely makes room for children's voices"),
    .init(id: "11-21", trDescription: "Televizyon, haberden eğlenceye ortak gündemi şekillendiren güçlü bir kamusal araç; temsil ve güvenilir bilgi sorumluluğunu da taşır.", trHook: "Aynı dizinin finalini hâlâ tartıştığın kişiye gönder", enDescription: "Television is a powerful public medium shaping shared attention through news and entertainment, with responsibilities for representation and reliable information.", enHook: "Send to someone you still debate that series finale with"),
    .init(id: "11-26", trDescription: "Sürdürülebilir ulaşım; hareketliliği düşük emisyonlu, güvenli, erişilebilir ve herkes için karşılanabilir hâle getirmeyi amaçlar.", trHook: "Şehirde daha iyi bir yol mümkün diyen biriyle paylaş", enDescription: "Sustainable transport aims to make mobility low-emission, safe, accessible and affordable for everyone.", enHook: "Share with someone who believes cities can move better"),
    .init(id: "11-27", trDescription: "Sürdürülebilir kalkınma için bilime katılım, araştırmacıların yanında toplumların da soru sorma, bilgi üretme ve çözümü şekillendirme hakkını güçlendirir.", trHook: "Bilimi kapalı kapılardan çıkaran kişiyle paylaş", enDescription: "Engagement in science for sustainable development strengthens communities' role in asking questions, producing knowledge and shaping solutions alongside researchers.", enHook: "Share with someone who brings science out from behind closed doors"),
    .init(id: "12-04", trDescription: "Kalkınma bankaları uzun vadeli altyapı, iklim ve sosyal yatırımları finanse eder; şeffaflık ve kamusal fayda bu rolün temelidir.", trHook: "Finansın toplumsal etkisini önemseyen biriyle paylaş", enDescription: "Development banks finance long-term infrastructure, climate and social investment; transparency and public benefit are central to that role.", enHook: "Share with someone who cares about finance's public impact"),
    .init(id: "12-05", trDescription: "Gönüllülük zaman, beceri ve dayanışmayı topluluk yararına paylaşmaktır; iyi gönüllülük yerel ihtiyacı dinler ve emeğin yerini almaya çalışmaz.", trHook: "Zamanını iyiliğe dönüştüren gönüllüye gönder", enDescription: "Volunteering shares time, skill and solidarity for community benefit; good volunteering listens to local need and does not replace paid work.", enHook: "Send to a volunteer who turns time into good"),
    .init(id: "12-07", trDescription: "Sivil havacılık insanları ve ekonomileri bağlarken ortak güvenlik standartlarına, erişilebilirliğe ve daha düşük iklim etkisine ihtiyaç duyar.", trHook: "Uçuş rotalarını ezbere bilen kişiye gönder", enDescription: "Civil aviation connects people and economies while depending on shared safety standards, accessibility and lower climate impact.", enHook: "Send to someone who knows flight routes by heart"),
    .init(id: "12-11", trDescription: "Dağlar tatlı suyun, biyolojik çeşitliliğin ve milyonlarca insanın yaşam alanıdır; iklim değişikliği yükseklerde de hızlı iz bırakır.", trHook: "Zirveye giden yolu sevdiğin kişiye gönder", enDescription: "Mountains hold freshwater, biodiversity and homes for millions; climate change leaves fast-moving marks at high altitude too.", enHook: "Send to someone you love taking the trail upward with"),
    .init(id: "12-15", trDescription: "Türk dili ailesi, geniş bir coğrafyada farklı tarih ve kültürleri taşıyan akraba dilleri buluşturur; çeşitlilik ortak mirasın parçasıdır.", trHook: "Kelimelerin akrabalığını merak eden kişiye gönder", enDescription: "The Turkic language family connects related languages carrying different histories and cultures across a wide geography; diversity is part of the shared heritage.", enHook: "Send to someone curious about how words are related"),
    .init(id: "12-17", trDescription: "17 Aralık 1903'te Wright kardeşler motorlu ve kontrollü uçuşu gerçekleştirdi; birkaç saniyelik yolculuk ulaşım tarihini değiştirdi.", trHook: "Uçma fikrine hâlâ hayran olan kişiye gönder", enDescription: "On 17 December 1903, the Wright brothers achieved powered, controlled flight; a journey of seconds changed transport history.", enHook: "Send to someone still amazed by the idea of flight"),
    .init(id: "12-20", trDescription: "İnsani dayanışma, ortak sorunlarda en çok etkilenenleri dinleyip sorumluluğu ve kaynakları adil biçimde paylaşmaktır.", trHook: "Kimseyi geride bırakmamaya çalışan kişiye gönder", enDescription: "Human solidarity means listening to those most affected by shared problems and distributing responsibility and resources fairly.", enHook: "Send to someone who works to leave no one behind"),
    .init(id: "12-21", trDescription: "Basketbol, 1891'de kapalı alanda oynanacak bir kış sporu olarak başladı; bugün sokak potalarından dünya sahnesine uzanıyor.", trHook: "Son saniye şutunu emanet edeceğin kişiye gönder", enDescription: "Basketball began in 1891 as an indoor winter game and now stretches from street hoops to the world stage.", enHook: "Send to someone you would trust with the last-second shot"),
    .init(id: "12-22", trDescription: "WhaDay bugün kış sofrasını kutluyor: sıcak bir tabak, uzun bir sohbet ve dışarıdaki soğuğa karşı paylaşılan küçük bir alan.", trHook: "Kışın aynı sofrada ısınmak istediğin kişiye gönder", enDescription: "WhaDay celebrates the winter table today: a warm plate, a long conversation and a small shared refuge from the cold outside.", enHook: "Send to someone you want beside you at a warm winter table")
]

private let nonOfficialSources: [String: SourcePatch] = [
    "07-03": .init(organization: "Zero Waste Europe", url: "https://zerowasteeurope.eu/"),
    "07-10": .init(organization: "Nikola Tesla Museum", url: "https://tesla-museum.org/en/"),
    "07-24": .init(organization: "Encyclopaedia Britannica", url: "https://www.britannica.com/biography/Simon-Bolivar"),
    "07-29": .init(organization: "WWF", url: "https://tigers.panda.org/"),
    "08-10": .init(organization: "World Lion Day", url: "https://www.worldlionday.com/"),
    "08-20": .init(organization: "London School of Hygiene and Tropical Medicine", url: "https://www.lshtm.ac.uk/newsevents/events/world-mosquito-day"),
    "09-01": .init(organization: "UNESCO", url: "https://www.unesco.org/"),
    "09-04": .init(organization: "National Wildlife Day", url: "https://nationalwildlifeday.com/"),
    "09-14": .init(organization: "Vatican News", url: "https://www.vaticannews.va/en/liturgical-holidays/feast-of-the-exaltation-of-the-holy-cross.html"),
    "09-22": .init(organization: "European Mobility Week", url: "https://mobilityweek.eu/"),
    "09-25": .init(organization: "International Pharmaceutical Federation", url: "https://www.fip.org/world-pharmacists-day"),
    "10-14": .init(organization: "ISO", url: "https://www.iso.org/world-standards-day.html"),
    "10-28": .init(organization: "ASIFA", url: "https://asifa.net/international-animation-day/"),
    "11-01": .init(organization: "Vatican", url: "https://www.vatican.va/"),
    "11-07": .init(organization: "Inuit Circumpolar Council", url: "https://www.inuitcircumpolar.com/international-inuit-day/"),
    "11-08": .init(organization: "ISOCARP", url: "https://isocarp.org/activities/world-town-planning-day/"),
    "11-09": .init(organization: "The American Presidency Project", url: "https://www.presidency.ucsb.edu/documents/proclamation-8171-world-freedom-day-2007"),
    "12-17": .init(organization: "US Library of Congress", url: "https://www.loc.gov/item/today-in-history/december-17/"),
    "12-22": .init(organization: "WhaDay", url: "https://whaday.app/")
]

private let editorialIDs: Set<String> = ["12-22"]
private let nonOfficialIDs = Set(nonOfficialSources.keys).subtracting(editorialIDs)
private let targetIDs = Set(copy.map(\.id))
private let officialIDs = targetIDs.subtracting(nonOfficialIDs).subtracting(editorialIDs)
private let considerateIDs: Set<String> = ["07-11", "08-20", "11-07"]
private let relationshipIDs: Set<String> = ["09-05", "10-05", "10-29", "11-20", "12-05", "12-20", "12-22"]
private let natureIDs: Set<String> = ["07-03", "07-06", "07-12", "07-29", "08-10", "08-27", "09-04", "09-07", "09-16", "09-20", "09-22", "09-29", "10-07", "10-23", "12-11"]
private let cultureIDs: Set<String> = ["07-07", "07-24", "08-11", "09-01", "09-08", "09-14", "09-23", "09-30", "10-27", "10-28", "11-01", "11-07", "11-21", "12-15"]
private let scienceIDs: Set<String> = ["07-10", "07-20", "10-04", "11-10", "11-27", "12-07", "12-17"]
private let sportIDs: Set<String> = ["12-21"]
private let professionIDs: Set<String> = ["09-25", "10-09"]
private let foodIDs: Set<String> = ["09-29", "12-22"]

guard copy.count == 58, targetIDs.count == copy.count else {
    fatalError("Expected 58 unique H2 records")
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
    if relationshipIDs.contains(id) { return "relationships" }
    if foodIDs.contains(id) { return "food-and-drink" }
    if natureIDs.contains(id) { return "animals-and-nature" }
    if cultureIDs.contains(id) { return "culture-and-arts" }
    if scienceIDs.contains(id) { return "science-and-curiosity" }
    if sportIDs.contains(id) { return "sport-and-movement" }
    if professionIDs.contains(id) { return "professions" }
    if id == "08-20" { return "health-and-awareness" }
    return "civil-society"
}

private func curateLocalized(_ language: String) throws {
    let url = root.appendingPathComponent("WhaDayNative/Data/\(language).json")
    var days = try JSONDecoder().decode([LocalizedDay].self, from: Data(contentsOf: url))
    let byID = Dictionary(uniqueKeysWithValues: copy.map { ($0.id, $0) })
    guard days.count == 366, targetIDs.isSubset(of: Set(days.map(\.id))) else {
        fatalError("\(language) corpus is missing H2 records")
    }
    for index in days.indices {
        guard let patch = byID[days[index].id] else { continue }
        days[index].description = language == "tr" ? patch.trDescription : patch.enDescription
        days[index].sharingHook = language == "tr" ? patch.trHook : patch.enHook
        if days[index].id == "09-01" {
            days[index].title = language == "tr" ? "Bilgi Günü (Eski Sovyet Coğrafyası)" : "Knowledge Day (Former Soviet Countries)"
        } else if days[index].id == "11-09" {
            days[index].title = language == "tr" ? "Dünya Özgürlük Günü (ABD)" : "World Freedom Day (United States)"
        } else if days[index].id == "12-22" {
            days[index].title = language == "tr" ? "Kış Sofrası Günü" : "Winter Table Day"
            days[index].emoji = "🍲"
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
        records[index]["sensitivity"] = considerateIDs.contains(id) ? "considerate" : "standard"
        records[index]["shareability"] = considerateIDs.contains(id) ? 2 : (relationshipIDs.contains(id) ? 5 : (id == "11-09" || id == "09-14" || id == "11-01" ? 3 : 4))
        records[index]["audience"] = considerateIDs.contains(id) ? ["careful-sharing"] : (relationshipIDs.contains(id) ? ["friend", "community"] : ["community"])
        records[index]["scope"] = editorialIDs.contains(id) ? "whaday-editorial" : (id == "09-01" || id == "09-04" || id == "09-14" || id == "11-01" || id == "11-09" ? "culture-specific" : "international")
        if officialIDs.contains(id) {
            records[index]["authority"] = "official"
            records[index]["source"] = ["organization": unMaster.organization, "url": unMaster.url, "checkedAt": "2026-08-14"]
        } else if let source = nonOfficialSources[id], !editorialIDs.contains(id) {
            records[index]["authority"] = "cultural"
            records[index]["source"] = ["organization": source.organization, "url": source.url, "checkedAt": "2026-08-14"]
        } else {
            records[index]["authority"] = "editorial"
            records[index].removeValue(forKey: "source")
        }
        if id == "12-22" { records[index]["symbol"] = "🍲" }
        updated += 1
    }
    guard updated == 58 else { fatalError("Expected 58 metadata updates, wrote \(updated)") }
    let output = try JSONSerialization.data(withJSONObject: records, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    try output.write(to: url, options: .atomic)
}

try curateLocalized("tr")
try curateLocalized("en")
try curateMetadata()
print("Curated 58 July-December institutional records")
