import Foundation

enum EditorialTone {
    case playful
    case warm
    case curious
    case mindful
    case remembrance
}

struct EditorialContent {
    let eyebrow: String
    let fact: String
    let prompt: String
    let shareMessage: String
    let tone: EditorialTone

    static func forEvent(_ event: DayEvent) -> EditorialContent {
        let language = DayEventStore.language
        let tone = tone(for: event)
        let lens = lens(for: event, tone: tone)

        if let curated = curated[event.id] {
            return language == "tr" ? curated.tr : curated.en
        }

        if language == "tr" {
            return EditorialContent(
                eyebrow: tone == .remembrance ? "BUGÜNÜN NOTU" : "BUGÜNÜN BAHANESİ",
                fact: fallbackFactTR(for: event, tone: tone, lens: lens),
                prompt: fallbackPromptTR(for: event, tone: tone, lens: lens),
                shareMessage: fallbackMessageTR(for: event, tone: tone, lens: lens),
                tone: tone
            )
        }

        return EditorialContent(
            eyebrow: tone == .remembrance ? "TODAY'S NOTE" : "TODAY'S EXCUSE",
            fact: fallbackFactEN(for: event, tone: tone, lens: lens),
            prompt: fallbackPromptEN(for: event, tone: tone, lens: lens),
            shareMessage: fallbackMessageEN(for: event, tone: tone, lens: lens),
            tone: tone
        )
    }

    private static func tone(for event: DayEvent) -> EditorialTone {
        let normalized = event.title.lowercased()
        let remembranceWords = [
            "victim", "violence", "war", "holocaust", "suicide", "slavery", "terror",
            "kurban", "şiddet", "savaş", "soykırım", "intihar", "köle", "terör", "anma"
        ]
        if remembranceWords.contains(where: normalized.contains) { return .remembrance }

        switch event.category {
        case "culture", "community", "diversity": return .warm
        case "knowledge", "science", "growth": return .curious
        case "peace", "mindfulness", "reflection", "wellness": return .mindful
        default: return .playful
        }
    }

    private enum Lens {
        case food, animal, books, music, screen, science, nature, movement
        case family, friendship, love, language, profession, health, equality
        case country, faith, rest, play, remembrance, general
    }

    private static func lens(for event: DayEvent, tone: EditorialTone) -> Lens {
        if tone == .remembrance { return .remembrance }
        let title = event.title.lowercased()

        let groups: [(Lens, [String])] = [
            (.food, ["pizza", "nutella", "oreo", "kahve", "coffee", "çay", "tea", "süt", "milk", "turta", "pie", "makarna", "pasta", "patates", "potato", "kek", "cake", "şeker", "candy", "bacon", "tahıl", "cereal", "baklagil", "food", "gıda", "ton balığı"]),
            (.animal, ["kedi", "cat", "köpek", "dog", "panda", "penguen", "penguin", "kaplan", "tiger", "aslan", "lion", "fil", "elephant", "arı", "bee", "yaban hayat", "wildlife", "hayvan", "animal", "markhor", "kar leoparı", "sivrisinek"]),
            (.books, ["kitap", "book", "şiir", "poetry", "okuma", "reading", "yazar", "author", "roald dahl", "harry potter", "winnie the pooh"]),
            (.music, ["müzik", "music", "piyano", "piano", "caz", "jazz", "radyo", "radio", "ses günü", "voice day", "steelpan", "cecilia"]),
            (.screen, ["star wars", "geleceğe dönüş", "back to the future", "barbie", "video oyunu", "video game", "televizyon", "television", "animasyon", "animation", "tiyatro", "theatre", "theater", "emoji"]),
            (.science, ["bilim", "science", "matematik", "math", "pi günü", "pi day", "uzay", "space", "asteroid", "ufo", "tesla", "mühendis", "engineer", "mucit", "inventor", "mantık", "logic", "meteoroloji", "meteorolog", "ışık günü", "light day"]),
            (.nature, ["dünya günü", "earth day", "çevre", "environment", "okyanus", "ocean", "orman", "forest", "göl", "lake", "sulak", "wetland", "su günü", "water day", "biyolojik", "biodiversity", "ozon", "ozone", "temiz hava", "clean air", "sıfır atık", "zero waste", "geri dönüşüm", "recycling", "dağlar", "mountain"]),
            (.movement, ["spor", "sport", "futbol", "football", "bisiklet", "bicycle", "basketbol", "basketball", "yoga", "oyun günü", "play day", "fair play"]),
            (.family, ["aile", "family", "ebeveyn", "parent", "kardeş", "sibling", "çocuk günü", "children's day", "çocuklar günü"]),
            (.friendship, ["dostluk", "friendship", "bağlantı", "connection", "nezaket", "kindness", "sarıl", "hug"]),
            (.love, ["sevgili", "valentine", "gül günü", "rose day", "evlilik teklifi", "proposal", "öpme", "kiss"]),
            (.language, ["dil günü", "language day", "anadil", "mother language", "çeviri", "translation", "okuryazarlık", "literacy", "braille", "işaret dilleri", "sign languages"]),
            (.profession, ["öğretmen", "teacher", "eczacı", "pharmacist", "hakim", "judge", "tesisat", "plumb", "denizci", "seafarer", "gönüllü", "volunteer", "barış gücü", "peacekeeper", "işletmeler", "enterprises"]),
            (.health, ["sağlık", "health", "hastalık", "disease", "parkinson", "diyabet", "diabetes", "epilepsi", "epilepsy", "hemofili", "haemophilia", "hemophilia", "tüberküloz", "tuberculosis", "sıtma", "malaria", "hepatit", "hepatitis", "aids", "hiv", "zatürre", "pneumonia", "osteoporoz", "osteoporosis", "menopoz", "menopause", "hijyen", "hygiene", "ruh sağlığı", "mental health", "otizm", "autism", "engelli", "disability"]),
            (.equality, ["eşit", "equal", "ayrımcılık", "discrimination", "hakları", "rights", "özgürlük", "freedom", "görünürlük", "visibility", "lgbtq", "lezbiyen", "lesbian", "interseks", "intersex", "sosyal adalet", "social justice", "hoşgörü", "tolerance", "kadınlar günü", "women's day", "kız çocukları"]),
            (.country, ["bağımsızlık", "independence", "ulusal gün", "national day", "devlet günü", "statehood", "kurtuluş günü", "liberation day", "zafer günü", "victory day", "kanada günü", "bastille", "devrim günü"]),
            (.faith, ["aziz", "saint", "azize", "noel", "christmas", "epifani", "epiphany", "meryem", "nirvana", "ramazan", "easter", "festivali", "festival", "yortusu", "bayramı"]),
            (.rest, ["uyku", "sleep", "banyo", "bath", "iç barış", "inner peace", "kendine bakım", "self-care", "dikkatli an", "mindful", "barışçıl duruş", "açıklık anı", "şükran", "gratitude", "düşünme günü", "thinking day"]),
            (.play, ["şapka", "hat day", "puantiye", "polka dot", "hiçbir şey", "nothing day", "şaka", "fools", "korsan", "pirate", "gökdelen", "skyscraper", "tick tock", "festivus"])
        ]

        return groups.first { _, words in words.contains(where: title.contains) }?.0 ?? .general
    }

    private static func fallbackFactTR(for event: DayEvent, tone: EditorialTone, lens: Lens) -> String {
        switch lens {
        case .food: return "Diyeti yarına bırakmak ya da sevdiğin lezzeti paylaşmak için takvimden onay çıktı."
        case .animal: return "Galerisi pati, tüy ya da vahşi yaşam fotoğraflarıyla dolu olanların bahanesi hazır."
        case .books: return "Yarım kalan kitaba dönmek ya da birine ‘bunu mutlaka oku’ demek için iyi gün."
        case .music: return "Kulaklığı tak, favorini aç; bugün ses biraz daha yüksek olabilir."
        case .screen: return "Repliği bilen, evreni ezberleyen ya da maraton bahanesi arayan biri mutlaka vardır."
        case .science: return "Merak ettiğin bir şeyi kurcalamak ve öğrendiğini birine anlatmak için takvimden izin çıktı."
        case .nature: return "Ekrana biraz daha az, etrafındaki dünyaya biraz daha çok bakmak için güzel bir hatırlatma."
        case .movement: return "Rekabetten önce birlikte hareket etmenin ve oyunun birleştirici tarafını hatırlama günü."
        case .family: return "Aile grubunu sessizce okumak yerine ilk mesajı atmak için bahanen hazır."
        case .friendship: return "İçinden ‘bunu kesin ona atmalıyım’ dediğin kişi bu kartın sahibi."
        case .love: return "Büyük cümle gerekmiyor; aklından geçtiğini belli eden küçük bir mesaj yeter."
        case .language: return "Kendini anlatabilmenin ve başka birini gerçekten anlayabilmenin değerini hatırlatıyor."
        case .profession: return "İşleri yürütürken çoğu zaman görünmeyen bir emeğe teşekkür bırakmak için doğru gün."
        case .health: return "Doğru bilgiyi paylaşmak, yaşayanları dinlemek ve görünürlüğü büyütmek için bir hatırlatma."
        case .equality: return "Eşitlik kendiliğinden gelmiyor; görmek, dinlemek ve ses vermekle büyüyor."
        case .country: return "Başka bir ülkenin hikâyesine, kültürüne ve hafızasına küçük bir pencere açılıyor."
        case .faith: return "Bu günü kutlayanlar için gelenek, topluluk ve paylaşma zamanı."
        case .rest: return "Günün hızını biraz düşürmek ve kendine alan açmak için takvim bahaneyi hazırlamış."
        case .play: return "Ciddiyete kısa bir mola verip günü biraz daha eğlenceli hâle getirmek serbest."
        case .remembrance: return "Durup hatırlamak, yaşayanları dinlemek ve aynı acıların tekrarlanmaması için konuşmak önemli."
        case .general:
            switch tone {
            case .curious: return "Daha önce duymadıysan merak etmek, biliyorsan birine anlatmak için iyi bir fırsat."
            case .mindful: return "Günün temposunda küçük ama anlamlı bir durak açıyor."
            case .warm: return "Birini hatırlamak ve yeniden bağ kurmak için güzel bir neden."
            case .playful: return "Takvimin bu bahanesini görür görmez aklına biri geldiyse görev tamam."
            case .remembrance: return "Hatırlamak ve konuşmak için önemli bir gün."
            }
        }
    }

    private static func fallbackPromptTR(for event: DayEvent, tone: EditorialTone, lens: Lens) -> String {
        switch lens {
        case .food: return "Birlikte yiyeceğin kişiye gönder"
        case .animal: return "Bir hayvan dostuna gönder"
        case .books: return "Bir kitap kurduna gönder"
        case .music: return "Playlist’ine güvendiğin kişiye gönder"
        case .screen: return "Aynı repliği ezberlediğin kişiye gönder"
        case .science: return "En meraklı arkadaşına gönder"
        case .nature: return "Doğa kaçamağı borçlu olduğuna gönder"
        case .movement: return "Takım arkadaşına gönder"
        case .family: return "Aile grubuna bırak"
        case .friendship: return "İlk aklına gelen arkadaşına gönder"
        case .love: return "Kalbinden geçene gönder"
        case .language: return "Kelimeleri seven birine gönder"
        case .profession: return "Emeğine teşekkür etmek istediğine gönder"
        case .health: return "Bilgiyle ve özenle paylaş"
        case .equality: return "Daha çok kişiye ulaştır"
        case .country: return "O kültüre meraklı birine gönder"
        case .faith: return "Kutlayan birine gönder"
        case .rest: return "Birlikte yavaşlayacağın kişiye gönder"
        case .play: return "Gülümseyeceğini bildiğin kişiye gönder"
        case .remembrance: return "Saygıyla paylaş"
        case .general: return tone == .remembrance ? "Saygıyla paylaş" : "Aklına gelen kişiye gönder"
        }
    }

    private static func fallbackMessageTR(for event: DayEvent, tone: EditorialTone, lens: Lens) -> String {
        switch lens {
        case .food: return "Bugün \(event.title) imiş. Bunu birlikte kutlayalım dedim. — WhaDay"
        case .animal: return "Bugün \(event.title) imiş. Bu kartı görünce aklıma sen geldin. 🐾 — WhaDay"
        case .books: return "Bugün \(event.title). Bana bir kitap önerme sırası sende. 📚 — WhaDay"
        case .music: return "Bugün \(event.title). Günün şarkısını senden bekliyorum. 🎧 — WhaDay"
        case .screen: return "Bugün \(event.title). Bu akşamın programı belli oldu sanırım. — WhaDay"
        case .science: return "Bugün \(event.title). Günün merakını sana bırakıyorum. 💡 — WhaDay"
        case .family: return "Bugün \(event.title). Mesaj atmak için bahanem hazırdı; ben de kullandım. — WhaDay"
        case .friendship: return "Bugün \(event.title). Kartı görür görmez aklıma sen geldin. — WhaDay"
        case .love: return "Bugün \(event.title). Takvimin bahanesine ihtiyacım yoktu ama yine de sana yazdım. — WhaDay"
        case .remembrance: return "Bugün \(event.title). Hatırlamak ve hatırlatmak istedim. — WhaDay"
        default: return "Bugün \(event.title) olduğunu biliyor muydun? Bunu görmen gerektiğini düşündüm. — WhaDay"
        }
    }

    private static func fallbackFactEN(for event: DayEvent, tone: EditorialTone, lens: Lens) -> String {
        switch lens {
        case .food: return "The calendar just approved postponing the diet and sharing something delicious."
        case .animal: return "A ready-made excuse for anyone whose camera roll is full of paws, feathers or wildlife."
        case .books: return "A fine reason to reopen that unfinished book or tell someone, ‘you have to read this.’"
        case .music: return "Put on your headphones and press play; the volume can be a little louder today."
        case .screen: return "Someone knows every quote, memorized the whole universe or needs a marathon excuse."
        case .science: return "Permission to follow a curious thought and tell someone what you discover."
        case .nature: return "A gentle reminder to look a little less at the screen and more at the world around you."
        case .movement: return "A reminder that moving and playing together matter more than the score."
        case .family: return "Your excuse to stop silently reading the family chat and send the first message."
        case .friendship: return "The person you instantly thought of is exactly who this card belongs to."
        case .love: return "No grand speech required; one small message can say they crossed your mind."
        case .language: return "A reminder of how much it matters to express yourself and truly understand someone else."
        case .profession: return "A good day to thank the often unseen work that keeps things moving."
        case .health: return "A reminder to share reliable information, listen to lived experience and make it visible."
        case .equality: return "Equality does not happen by itself; it grows when we notice, listen and speak up."
        case .country: return "A small window into another country's history, culture and shared memory."
        case .faith: return "A time of tradition, community and sharing for those who observe it."
        case .rest: return "The calendar supplied a reason to slow down and make a little room for yourself."
        case .play: return "Permission granted to pause the seriousness and make the day more fun."
        case .remembrance: return "A moment to remember, listen and talk so the same pain is not repeated."
        case .general:
            switch tone {
            case .curious: return "If it is new to you, get curious; if you know it, tell someone."
            case .mindful: return "A small but meaningful pause in a busy day."
            case .warm: return "A lovely reason to remember someone and reconnect."
            case .playful: return "If someone came to mind immediately, the calendar has done its job."
            case .remembrance: return "A moment worth remembering and talking about."
            }
        }
    }

    private static func fallbackPromptEN(for event: DayEvent, tone: EditorialTone, lens: Lens) -> String {
        switch lens {
        case .food: return "Send to someone who will share a bite"
        case .animal: return "Send to an animal person"
        case .books: return "Send to a bookworm"
        case .music: return "Send to the friend with the best playlist"
        case .screen: return "Send to the friend who knows every quote"
        case .science: return "Send to your most curious friend"
        case .nature: return "Send to someone who owes you an escape"
        case .movement: return "Send to your teammate"
        case .family: return "Drop it in the family chat"
        case .friendship: return "Send to the first friend you thought of"
        case .love: return "Send to the one in your heart"
        case .language: return "Send to someone who loves words"
        case .profession: return "Thank someone whose work matters"
        case .health: return "Share with care and context"
        case .equality: return "Help it reach more people"
        case .country: return "Send to someone curious about the culture"
        case .faith: return "Send to someone observing today"
        case .rest: return "Send to someone you can slow down with"
        case .play: return "Send to someone who will smile"
        case .remembrance: return "Share with care"
        case .general: return tone == .remembrance ? "Share with care" : "Send to the person you thought of"
        }
    }

    private static func fallbackMessageEN(for event: DayEvent, tone: EditorialTone, lens: Lens) -> String {
        switch lens {
        case .food: return "Apparently it's \(event.title). I think we should celebrate together. — WhaDay"
        case .animal: return "Apparently it's \(event.title). This card immediately made me think of you. 🐾 — WhaDay"
        case .books: return "It's \(event.title). Your turn to recommend my next read. 📚 — WhaDay"
        case .music: return "It's \(event.title). I'm waiting for your song of the day. 🎧 — WhaDay"
        case .screen: return "It's \(event.title). I think tonight's plans just made themselves. — WhaDay"
        case .science: return "It's \(event.title). Sending today's curiosity your way. 💡 — WhaDay"
        case .family: return "It's \(event.title). The calendar gave me an excuse to text, so I used it. — WhaDay"
        case .friendship: return "It's \(event.title). I saw this card and immediately thought of you. — WhaDay"
        case .love: return "It's \(event.title). I didn't need the calendar's excuse, but I texted you anyway. — WhaDay"
        case .remembrance: return "Today is \(event.title). A moment worth remembering. — WhaDay"
        default: return "Did you know today is \(event.title)? I thought you should see this. — WhaDay"
        }
    }

    private struct Pair {
        let tr: EditorialContent
        let en: EditorialContent
    }

    private static let curated: [String: Pair] = [
        "01-02": pair(
            trFact: "Isaac Asimov'un doğum günü, bilim kurgu meraklılarının bahanesine dönüşmüş.",
            trPrompt: "Bir bilim kurgu severe ışınla",
            trMessage: "Bugün Bilim Kurgu Günüymüş. Bu mesajı gelecekten yolladığımı varsay. 🚀 — WhaDay",
            enFact: "Isaac Asimov's birthday became a perfect excuse for science-fiction fans.",
            enPrompt: "Beam it to a sci-fi fan",
            enMessage: "Apparently it's Science Fiction Day. Pretend I sent this from the future. 🚀 — WhaDay",
            tone: .curious
        ),
        "01-03": pair(
            trFact: "Yılın en yavaş günlerinden biri: alarmı ertelemek bugün neredeyse kültürel bir görev.",
            trPrompt: "Uykucu arkadaşına gönder",
            trMessage: "Bugün Uyku Festivali Günüymüş. Sonunda resmî bir branşın var. 😴 — WhaDay",
            enFact: "One of the year's slowest days: hitting snooze is practically a cultural duty today.",
            enPrompt: "Send to your sleepiest friend",
            enMessage: "It's Festival of Sleep Day. You finally have an official sport. 😴 — WhaDay",
            tone: .playful
        ),
        "01-21": pair(
            trFact: "Sarılmak için özel bir sebebe gerek yok; ama takvim bugün bahaneyi hazır etmiş.",
            trPrompt: "Sarılmak istediğin kişiye gönder",
            trMessage: "Bugün Sarılma Günüymüş. Mesafeden bir tane bırakıyorum: 🫂 — WhaDay",
            enFact: "You never need a reason for a hug, but the calendar supplied one anyway.",
            enPrompt: "Send to someone who deserves a hug",
            enMessage: "It's Hugging Day. Leaving one here from a distance: 🫂 — WhaDay",
            tone: .warm
        ),
        "02-05": pair(
            trFact: "Bir kavanoz, bir kaşık ve paylaşmaya hiç niyeti olmayan milyonlarca insan.",
            trPrompt: "Nutella'sını saklayan kişiye gönder",
            trMessage: "Bugün Dünya Nutella Günü. Kavanozu paylaşmayacağını ikimiz de biliyoruz. 🍫 — WhaDay",
            enFact: "One jar, one spoon and millions of people with absolutely no intention of sharing.",
            enPrompt: "Send to the one hiding the jar",
            enMessage: "It's World Nutella Day. We both know you're not sharing the jar. 🍫 — WhaDay",
            tone: .playful
        ),
        "02-09": pair(
            trFact: "İnce hamur, kalın hamur ya da ananas tartışması: bugün herkes aynı masada.",
            trPrompt: "Pizza borcu olan kişiye gönder",
            trMessage: "Bugün Pizza Günüymüş. Bence bunu bir siparişle kutlamalısın. 🍕 — WhaDay",
            enFact: "Thin crust, deep dish or the pineapple debate: everyone is at the same table today.",
            enPrompt: "Send to someone who owes you pizza",
            enMessage: "It's Pizza Day. I think you should celebrate with an order. 🍕 — WhaDay",
            tone: .playful
        ),
        "02-14": pair(
            trFact: "Büyük jestlerden küçük notlara; bugün sevdiğini belli etmenin bahanesi hazır.",
            trPrompt: "Kalbinin sahibine gönder",
            trMessage: "Takvim Sevgililer Günü diyor; ben de en sevdiğim kişiye yazıyorum. ❤️ — WhaDay",
            enFact: "From grand gestures to tiny notes, today comes with a ready-made reason to show some love.",
            enPrompt: "Send to your favorite person",
            enMessage: "The calendar says Valentine's Day, so I'm texting my favorite person. ❤️ — WhaDay",
            tone: .warm
        ),
        "02-29": pair(
            trFact: "Dört yılda bir gelen bu tarih, nadir hastalıklarla yaşayan insanların görünürlüğünü büyütüyor.",
            trPrompt: "Nadir olanı görünür kıl",
            trMessage: "Bugün Nadir Hastalıklar Günü. Nadir olmak görünmez olmak demek değil. 🦓 — WhaDay",
            enFact: "This once-in-four-years date helps make people living with rare diseases more visible.",
            enPrompt: "Make rare visible",
            enMessage: "It's Rare Disease Day. Rare should never mean invisible. 🦓 — WhaDay",
            tone: .mindful
        ),
        "03-14": pair(
            trFact: "3,14 yalnızca bir sayı değil; matematikçilerin tatlı yiyebilmek için bulduğu kusursuz bahane.",
            trPrompt: "En hesaplı arkadaşına gönder",
            trMessage: "Bugün Pi Günü. Kutlamayı 3,14 dilimle sınırlandırabilirsen bravo. 🥧 — WhaDay",
            enFact: "3.14 is more than a number; it is a mathematician's perfect excuse to eat pie.",
            enPrompt: "Send to your most calculated friend",
            enMessage: "It's Pi Day. Bonus points if you stop at 3.14 slices. 🥧 — WhaDay",
            tone: .curious
        ),
        "04-01": pair(
            trFact: "Bugün duyduğun her şeye küçük bir şüphe payı bırak. Bu cümle dahil.",
            trPrompt: "Kolay kanan arkadaşına gönder",
            trMessage: "Bugün 1 Nisan. Sana şaka yapmayacağım… şimdilik. 👀 — WhaDay",
            enFact: "Leave a little room for doubt in everything you hear today. Including this sentence.",
            enPrompt: "Send to your most gullible friend",
            enMessage: "It's April Fools' Day. I won't prank you… yet. 👀 — WhaDay",
            tone: .playful
        ),
        "08-08": pair(
            trFact: "İnsanlar kedileri evcilleştirdiğini sanıyor. Kedilerin bu konuda farklı bir anlatısı var.",
            trPrompt: "Bir kedi çalışanına gönder",
            trMessage: "Bugün Dünya Kedi Günü. Patronuna benden selam söyle. 🐈 — WhaDay",
            enFact: "Humans think they domesticated cats. Cats tell that story very differently.",
            enPrompt: "Send to a cat employee",
            enMessage: "It's International Cat Day. Say hi to your boss for me. 🐈 — WhaDay",
            tone: .playful
        ),
        "08-13": pair(
            trFact: "Dünya nüfusunun yaklaşık onda biri solak; bugün makaslarla verdikleri mücadeleyi alkışlıyoruz.",
            trPrompt: "Solak arkadaşına gönder",
            trMessage: "Bugün Dünya Solaklar Günüymüş. Makaslarla savaşına saygım sonsuz. ✋ — WhaDay",
            enFact: "Roughly one in ten people is left-handed. Today we salute their lifelong battle with scissors.",
            enPrompt: "Send to your left-handed friend",
            enMessage: "It's Lefthanders Day. I respect your lifelong battle with scissors. ✋ — WhaDay",
            tone: .playful
        ),
        "08-26": pair(
            trFact: "Bugün yürüyüş biraz uzun, ödül maması biraz bol olabilir. İtiraz edeceklerini sanmıyoruz.",
            trPrompt: "Bir köpek insanına gönder",
            trMessage: "Bugün Dünya Köpek Günü. Evdeki asıl sahibin günü kutlu olsun. 🐕 — WhaDay",
            enFact: "The walk can be longer and the treats more generous today. We doubt they'll object.",
            enPrompt: "Send to a dog person",
            enMessage: "It's International Dog Day. Happy day to the real owner of your home. 🐕 — WhaDay",
            tone: .warm
        ),
        "10-01": pair(
            trFact: "Sabah konuşmadan önce kahve isteyenlerin takvimde resmî olmasa da tartışmasız bir günü var.",
            trPrompt: "Kahvesiz konuşamayan kişiye gönder",
            trMessage: "Bugün Dünya Kahve Günü. Bunu okurken elinde fincan olduğuna eminim. ☕️ — WhaDay",
            enFact: "People who need coffee before conversation finally have an undisputed day on the calendar.",
            enPrompt: "Send to someone who runs on coffee",
            enMessage: "It's International Coffee Day. I'm certain you're holding a cup right now. ☕️ — WhaDay",
            tone: .playful
        ),
        "10-21": pair(
            trFact: "Gelecek geldi, uçan kaykaylar hâlâ gecikti. DeLorean'ı olan haber versin.",
            trPrompt: "Film replikleriyle yaşayan kişiye gönder",
            trMessage: "Bugün Geleceğe Dönüş Günü. Yollar mı? Gideceğimiz yerde yollara ihtiyacımız yok. ⚡️ — WhaDay",
            enFact: "The future arrived, but hoverboards are still late. Anyone with a DeLorean, call us.",
            enPrompt: "Send to the friend who speaks in movie quotes",
            enMessage: "It's Back to the Future Day. Roads? Where we're going, we don't need roads. ⚡️ — WhaDay",
            tone: .playful
        ),
        "10-31": pair(
            trFact: "Kostümler, şekerler ve kapıyı çalanın kim olduğundan emin olamadığın tek gece.",
            trPrompt: "En ürkütücü arkadaşına gönder",
            trMessage: "Bugün Cadılar Bayramı. Normal hâlinle de konsepte uyuyorsun. 🎃 — WhaDay",
            enFact: "Costumes, candy and the one night you can never be sure who is at the door.",
            enPrompt: "Send to your spookiest friend",
            enMessage: "It's Halloween. Conveniently, your normal look already fits the theme. 🎃 — WhaDay",
            tone: .playful
        ),
        "11-13": pair(
            trFact: "Küçük bir iyilik bazen bütün günün yönünü değiştirir. Bugün ilk adımı sen at.",
            trPrompt: "İyi ki var dediğin kişiye gönder",
            trMessage: "Bugün Dünya Nezaket Günü. İyi ki varsın demek için bahanem hazır. 💛 — WhaDay",
            enFact: "A small act of kindness can redirect an entire day. Make the first move today.",
            enPrompt: "Send to someone you're grateful for",
            enMessage: "It's World Kindness Day. A perfect excuse to say I'm glad you're here. 💛 — WhaDay",
            tone: .warm
        ),
        "01-16": pair(
            trFact: "Kutlama programı oldukça yoğun: hiçbir şey yapma, sonra onu da yarına bırak.",
            trPrompt: "Programı hep dolu olana gönder",
            trMessage: "Bugün Hiçbir Şey Günü. Sonunda birlikte ustalaşabileceğimiz bir konu. — WhaDay",
            enFact: "Today's agenda is packed: do nothing, then postpone the rest until tomorrow.",
            enPrompt: "Send to your chronically busy friend",
            enMessage: "It's Nothing Day. Finally, something we can master together. — WhaDay",
            tone: .playful
        ),
        "01-18": pair(
            trFact: "Bal kavanozu, kırmızı tişört ve yüz dönümlük ormanda büyümüş koca bir çocukluk hatırası.",
            trPrompt: "Çocukluğunu özleyen birine gönder",
            trMessage: "Bugün Winnie the Pooh Günü. Biraz bal, biraz nostalji bıraktım. 🍯 — WhaDay",
            enFact: "A honey jar, a red shirt and a childhood memory raised in the Hundred Acre Wood.",
            enPrompt: "Send to someone missing their childhood",
            enMessage: "It's Winnie the Pooh Day. Leaving you a little honey and nostalgia. 🍯 — WhaDay",
            tone: .warm
        ),
        "01-20": pair(
            trFact: "Smokin giymiş gibi dolaşan, kayarak işe giden ve soğuğu hiç mesele etmeyenler sahnede.",
            trPrompt: "Penguen yürüyüşü yapan kişiye gönder",
            trMessage: "Bugün Penguen Farkındalık Günü. Yürüyüş stilin sonunda değer gördü. 🐧 — WhaDay",
            enFact: "They dress for dinner, commute by sliding and never complain about the cold.",
            enPrompt: "Send to someone with a penguin walk",
            enMessage: "It's Penguin Awareness Day. Your walking style finally has a moment. 🐧 — WhaDay",
            tone: .playful
        ),
        "01-29": pair(
            trFact: "Bir parçayı saatlerce arayıp sonunda kutunun altında bulmanın resmî bahanesi.",
            trPrompt: "Her şeyi çözebilen arkadaşına gönder",
            trMessage: "Bugün Bulmaca Günü. Eksik parçayı yine sen bulursun diye düşündüm. 🧩 — WhaDay",
            enFact: "An official excuse to search for one piece for hours and find it under the box.",
            enPrompt: "Send to the friend who solves everything",
            enMessage: "It's Puzzle Day. I figured you'd find the missing piece again. 🧩 — WhaDay",
            tone: .curious
        ),
        "03-06": pair(
            trFact: "Önce kremayı mı yersin, süte mi batırırsın? Bugünün kişilik testi bu kadar basit.",
            trPrompt: "Oreo’yu usulüne göre yiyene gönder",
            trMessage: "Bugün Oreo Günü. Ayırıp mı yiyorsun, direkt mi? Cevabın önemli. 🍪 — WhaDay",
            enFact: "Twist first or dunk immediately? Today's personality test is that simple.",
            enPrompt: "Send to someone with an Oreo ritual",
            enMessage: "It's Oreo Day. Twist or dunk? Your answer matters. 🍪 — WhaDay",
            tone: .playful
        ),
        "03-09": pair(
            trFact: "Pembe yalnızca bir renk değil; bugün bütün bir evren, gardırop ve ruh hâli.",
            trPrompt: "Pembe enerjisi taşıyan kişiye gönder",
            trMessage: "Bugün Barbie Günü. Kenarından biraz pembe enerji bırakıyorum. 🎀 — WhaDay",
            enFact: "Pink is not merely a color today; it is a universe, a wardrobe and a state of mind.",
            enPrompt: "Send to someone with pink energy",
            enMessage: "It's Barbie Day. Leaving a little pink energy here. 🎀 — WhaDay",
            tone: .playful
        ),
        "03-16": pair(
            trFact: "Günün planı: bambu ye, yuvarlan, kameraya bakmadan herkesi kendine hayran bırak.",
            trPrompt: "Panda gibi yaşayan arkadaşına gönder",
            trMessage: "Bugün Panda Günü. Enerji seviyemiz ve gün planımız nihayet eşleşti. 🐼 — WhaDay",
            enFact: "Today's plan: eat bamboo, roll around and charm everyone without looking at the camera.",
            enPrompt: "Send to your panda-coded friend",
            enMessage: "It's Panda Day. Our energy level and daily plan finally match. 🐼 — WhaDay",
            tone: .playful
        ),
        "03-20": pair(
            trFact: "Mutluluk bazen büyük haber değil; sevdiğin birinden gelen iki satırlık mesajdır.",
            trPrompt: "Yüzünü güldüren kişiye gönder",
            trMessage: "Bugün Dünya Mutluluk Günü. Benim günümü güzelleştiren kişiye yazıyorum. ☀️ — WhaDay",
            enFact: "Happiness is not always big news; sometimes it is a two-line message from someone you love.",
            enPrompt: "Send to someone who makes you smile",
            enMessage: "It's International Day of Happiness. I'm texting someone who makes my day better. ☀️ — WhaDay",
            tone: .warm
        ),
        "05-04": pair(
            trFact: "Uzak bir galaksi bugün biraz daha yakın. Güç seninle olsun; şarjın da yüzde yüz.",
            trPrompt: "Galaksiyi birlikte kurtaracağına gönder",
            trMessage: "Bugün Star Wars Günü. Güç seninle olsun; özellikle pazartesiyse. 🌌 — WhaDay",
            enFact: "A galaxy far, far away feels closer today. May your Force and battery both be full.",
            enPrompt: "Send to your galaxy-saving partner",
            enMessage: "It's Star Wars Day. May the Force be with you, especially if it's Monday. 🌌 — WhaDay",
            tone: .playful
        ),
        "05-06": pair(
            trFact: "Yemek yalnızca sayı değildir. Bugün tabağa suçluluk değil, keyif koyma günü.",
            trPrompt: "Birlikte güzel yemek yiyeceğine gönder",
            trMessage: "Bugün Diyet Yapmama Günü. Bence kutlama menüsünü birlikte seçmeliyiz. 🍽️ — WhaDay",
            enFact: "Food is more than a number. Today is for putting enjoyment, not guilt, on the plate.",
            enPrompt: "Send to your favorite dinner partner",
            enMessage: "It's No Diet Day. I think we should choose the celebration menu together. 🍽️ — WhaDay",
            tone: .warm
        ),
        "05-20": pair(
            trFact: "Küçük kanatlar, büyük iş: sofradaki çeşitliliğin görünmez kahramanları bugün başrolde.",
            trPrompt: "Arı gibi çalışan kişiye gönder",
            trMessage: "Bugün Dünya Arı Günü. Çalışkanlık seviyen yüzünden bu kart sana geldi. 🐝 — WhaDay",
            enFact: "Tiny wings, enormous work: the quiet heroes behind so much of our food take center stage.",
            enPrompt: "Send to the busiest bee you know",
            enMessage: "It's World Bee Day. Your work ethic earned you this card. 🐝 — WhaDay",
            tone: .curious
        ),
        "05-21": pair(
            trFact: "İnce belli, kupa ya da termos fark etmez; iyi sohbetin yanında çayın yeri hazır.",
            trPrompt: "Çay borcun olan kişiye gönder",
            trMessage: "Bugün Uluslararası Çay Günü. Demliği koy, konuşacaklarımız var. 🫖 — WhaDay",
            enFact: "Cup, glass or flask — tea already has a reserved seat beside a good conversation.",
            enPrompt: "Send to someone you owe a cup of tea",
            enMessage: "It's International Tea Day. Put the kettle on; we have things to discuss. 🫖 — WhaDay",
            tone: .warm
        ),
        "07-02": pair(
            trFact: "Gökyüzündeki her ışık uçak değil. Ama uzaylılar geldiyse ilk kimi arayacağını biliyorsun.",
            trPrompt: "Uzaylı istilasında arayacağına gönder",
            trMessage: "Bugün Dünya UFO Günü. Beni kaçırırlarsa kedime sen bakarsın. 🛸 — WhaDay",
            enFact: "Not every light in the sky is a plane. If aliens arrive, you already know who to call first.",
            enPrompt: "Send to your alien-invasion contact",
            enMessage: "It's World UFO Day. If I get abducted, you're looking after my cat. 🛸 — WhaDay",
            tone: .playful
        ),
        "07-08": pair(
            trFact: "Son bir bölüm, son bir maç, son bir görev… Bugün bu cümlenin kimseyi kandırmadığını kabul ediyoruz.",
            trPrompt: "Geceyi oyunda bitirdiğine gönder",
            trMessage: "Bugün Video Oyunu Günü. ‘Son el’ dediğine ikimiz de inanmıyoruz. 🎮 — WhaDay",
            enFact: "One last level, one last match, one last quest — today we admit that line fools nobody.",
            enPrompt: "Send to your late-night gaming friend",
            enMessage: "It's Video Game Day. Neither of us believes you when you say ‘one last game.’ 🎮 — WhaDay",
            tone: .playful
        ),
        "07-17": pair(
            trFact: "Bazen bir yüz, üç paragraftan daha çok şey anlatır. Özellikle de doğru seçilmişse.",
            trPrompt: "Sadece emojilerle konuşabildiğine gönder",
            trMessage: "Bugün Dünya Emoji Günü. İlişkimizi tek sembolle anlat: ____ 😶 — WhaDay",
            enFact: "Sometimes one tiny face says more than three paragraphs — especially when chosen well.",
            enPrompt: "Send to someone fluent in emoji",
            enMessage: "It's World Emoji Day. Describe our relationship with one symbol: ____ 😶 — WhaDay",
            tone: .playful
        ),
        "07-30": pair(
            trFact: "Aynı şakaya yıllardır gülebiliyorsanız arkadaşlığın kullanım süresi henüz dolmamış demektir.",
            trPrompt: "Yıllardır aynı saçmalığı yaptığına gönder",
            trMessage: "Bugün Dünya Dostluk Günü. Bunca yıldır bana katlandığın için tebrikler. 🫶 — WhaDay",
            enFact: "If you still laugh at the same joke after years, the friendship is nowhere near its expiry date.",
            enPrompt: "Send to your longtime partner in nonsense",
            enMessage: "It's International Friendship Day. Congratulations on putting up with me this long. 🫶 — WhaDay",
            tone: .warm
        ),
        "07-31": pair(
            trFact: "Mektup hâlâ gelmediyse baykuş yolunu kaybetmiş olabilir. Umudu kesmek için erken.",
            trPrompt: "Aynı binaya seçileceğine gönder",
            trMessage: "Bugün Harry Potter’ın doğum günü. Baykuş gelirse bana da haber ver. ⚡️ — WhaDay",
            enFact: "If the letter has not arrived, the owl may simply be lost. It is too early to give up hope.",
            enPrompt: "Send to your Hogwarts housemate",
            enMessage: "It's Harry Potter's birthday. Tell me if your owl arrives. ⚡️ — WhaDay",
            tone: .playful
        ),
        "09-19": pair(
            trFact: "Bugün bütün cümleler ‘Arrr’ ile başlayabilir; dilbilgisi polisi güverteye çıkamaz.",
            trPrompt: "Tayfanın en şüpheli üyesine gönder",
            trMessage: "Bugün Korsan Gibi Konuş Günü. Hazine haritasını getir, gerisini konuşuruz. 🏴‍☠️ — WhaDay",
            enFact: "Every sentence may begin with ‘Arrr’ today; the grammar police are not allowed on deck.",
            enPrompt: "Send to the shadiest member of your crew",
            enMessage: "It's Talk Like a Pirate Day. Bring the treasure map and we'll discuss the rest. 🏴‍☠️ — WhaDay",
            tone: .playful
        ),
        "10-25": pair(
            trFact: "Burgu, kalem, fiyonk ya da spagetti: doğru sos geldikten sonra şekil yalnızca ayrıntı.",
            trPrompt: "Makarna yapmasını beklediğine gönder",
            trMessage: "Bugün Dünya Makarna Günü. Sos senden, iştah benden. 🍝 — WhaDay",
            enFact: "Twists, tubes, bows or spaghetti — once the sauce arrives, shape is merely a detail.",
            enPrompt: "Send to someone who should cook pasta",
            enMessage: "It's World Pasta Day. You bring the sauce; I'll bring the appetite. 🍝 — WhaDay",
            tone: .playful
        ),
        "11-19": pair(
            trFact: "Gülümseten adı bir yana, güvenli sanitasyon sağlığın ve insan onurunun temel parçalarından biri.",
            trPrompt: "Gülümsetip düşündürmek için paylaş",
            trMessage: "Bugün Dünya Tuvalet Günü. Evet, gerçek bir gün; üstelik düşündüğünden daha önemli. 🚽 — WhaDay",
            enFact: "Funny name aside, safe sanitation is a fundamental part of health and human dignity.",
            enPrompt: "Share a smile and something important",
            enMessage: "It's World Toilet Day. Yes, it's real — and far more important than it sounds. 🚽 — WhaDay",
            tone: .curious
        ),
        "12-23": pair(
            trFact: "Mükemmel bayram baskısına karşı biraz sade dekor, bolca dürüstlük ve isteğe bağlı güreş.",
            trPrompt: "Bayram stresini paylaştığına gönder",
            trMessage: "Bugün Festivus. Önce dertlerimizi dökelim, güreşi sonra düşünürüz. — WhaDay",
            enFact: "A low-decor, high-honesty answer to holiday pressure, with optional wrestling.",
            enPrompt: "Send to your holiday-stress partner",
            enMessage: "It's Festivus. Let's air our grievances and consider the wrestling later. — WhaDay",
            tone: .playful
        ),
        "12-29": pair(
            trFact: "Yıl bitmeden yarım işleri kapatmak için son çağrı. Liste sana bakıyor, sen başka yere bakıyorsun.",
            trPrompt: "Her şeyi son güne bırakana gönder",
            trMessage: "Bugün Tick Tock Günü. Yıl bitiyor; o işi hâlâ yapmadın, değil mi? ⏳ — WhaDay",
            enFact: "Last call to close unfinished business before the year ends. The list is staring; you are looking away.",
            enPrompt: "Send to a professional procrastinator",
            enMessage: "It's Tick Tock Day. The year is ending and you still haven't done the thing, have you? ⏳ — WhaDay",
            tone: .playful
        ),
        "12-30": pair(
            trFact: "Yılın sonuna çıtır bir dipnot: bugün kahvaltı tartışmalarının en dumanlı tarafı sahnede.",
            trPrompt: "Kahvaltıyı ciddiye alana gönder",
            trMessage: "Bugün Bacon Günü. Yıl bitmeden tavaya son bir alkış. 🥓 — WhaDay",
            enFact: "A crispy footnote near the end of the year: breakfast's smokiest debate takes the stage.",
            enPrompt: "Send to someone serious about breakfast",
            enMessage: "It's Bacon Day. One last round of applause for the pan before the year ends. 🥓 — WhaDay",
            tone: .playful
        ),
        "12-31": pair(
            trFact: "Bir yıl daha kapanıyor. En iyi anları sakla, geri kalanını gece yarısında bırak.",
            trPrompt: "Yeni yıla birlikte gireceğin kişiye gönder",
            trMessage: "Yılın son günü. Yeni yılda da saçmalıklarımız devam etsin. ✨ — WhaDay",
            enFact: "Another year closes. Keep the best moments and leave the rest at midnight.",
            enPrompt: "Send to someone joining your next chapter",
            enMessage: "Last day of the year. Let's keep our nonsense going in the next one. ✨ — WhaDay",
            tone: .warm
        )
    ]

    private static func pair(
        trFact: String,
        trPrompt: String,
        trMessage: String,
        enFact: String,
        enPrompt: String,
        enMessage: String,
        tone: EditorialTone
    ) -> Pair {
        Pair(
            tr: EditorialContent(
                eyebrow: tone == .remembrance ? "BUGÜNÜN NOTU" : "BUGÜNÜN BAHANESİ",
                fact: trFact,
                prompt: trPrompt,
                shareMessage: trMessage,
                tone: tone
            ),
            en: EditorialContent(
                eyebrow: tone == .remembrance ? "TODAY'S NOTE" : "TODAY'S EXCUSE",
                fact: enFact,
                prompt: enPrompt,
                shareMessage: enMessage,
                tone: tone
            )
        )
    }
}

enum EditorialSymbol {
    static func forEvent(_ event: DayEvent) -> String {
        if let curated = curated[event.id] { return curated }
        if event.emoji != "🔔" { return event.emoji }

        switch event.category {
        case "science", "knowledge": return "💡"
        case "nature": return "🌿"
        case "peace": return "🕊️"
        case "wellness", "mindfulness": return "☀️"
        case "community", "diversity": return "🤝"
        case "culture": return "✦"
        case "sport": return "⚡️"
        default: return "✦"
        }
    }

    private static let curated: [String: String] = [
        "01-02": "🚀", "01-03": "😴", "01-16": "🛋️", "01-18": "🍯", "01-20": "🐧", "01-21": "🫂", "01-29": "🧩", "02-05": "🍫",
        "02-09": "🍕", "02-14": "❤️", "02-29": "🦓", "03-14": "🥧", "04-01": "👀",
        "03-06": "🍪", "03-09": "🎀", "03-16": "🐼", "03-20": "☀️", "05-04": "🌌", "05-06": "🍽️",
        "05-20": "🐝", "05-21": "🫖", "07-02": "🛸", "07-08": "🎮", "07-17": "😶", "07-30": "🫶", "07-31": "⚡️",
        "08-08": "🐈", "08-13": "✋", "08-26": "🐕", "09-19": "🏴‍☠️", "10-01": "☕️", "10-21": "⚡️",
        "10-25": "🍝", "10-31": "🎃", "11-13": "💛", "11-19": "🚽", "12-23": "✦", "12-29": "⏳", "12-30": "🥓", "12-31": "✨"
    ]
}
