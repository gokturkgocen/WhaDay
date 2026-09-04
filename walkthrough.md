# WhaDay 1.1.0 — Build 11

## Tasarım yönü

Bu sürüm, uygulamadaki eski yuvarlak kart ve kontrol dilini kaldırıp Aktif Sözlük benzeri editoryal sistemi tek kaynak hâline getirir: keskin yüzeyler, serif başlık hiyerarşisi, ince saç çizgileri ve kompakt 36 pt kontroller. Dokunma alanları 44 pt olarak korunur. Uygulamadaki tüm özel sheet akışlarında sürükleme tutamacı görünürdür.

## App Store vitrini

Mağaza seti yalnızca uygulama içi ekran görüntülerinden oluşmaz. Her görsel, özelliğin duygusunu taşıyan bir sahne ile gerçek uygulama arayüzünü birlikte kullanır. Çıktıların tamamı `1320 × 2868` boyutundadır.

1. `marketing/app-store/v1.1.0/01-bugun-ne-gunuymus.jpg` — günlük keşif ve ana ekran
2. `marketing/app-store/v1.1.0/02-bizim-sayacimiz.jpg` — ortak alan ve dolu geri sayım listesi
3. `marketing/app-store/v1.1.0/03-o-gunun-iddiasi.jpg` — sonuçlanmış arkadaş iddiası ve borç senedi
4. `marketing/app-store/v1.1.0/04-muhurlu-kapsul.jpg` — iki katılımcılı, mühürlü zaman kapsülü
5. `marketing/app-store/v1.1.0/05-gunun-sarkisi.jpg` — atanmış şarkı, sanatçı ve dinleme aksiyonu

Son üç ekranın verileri yalnızca `-seedStoreDayClub` UI-test başlatma argümanıyla etkinleşen süreç içi vitrin fixture'larından gelir. Normal uygulama verisi veya kullanıcı kalıcılığı değiştirilmez.

## Doğrulama

- Normal test paketi: 71 birim testi; 70 geçti, isteğe bağlı tam render kapısı 1 kez atlandı, hata yok.
- UI paketi: 7 test geçti, hata yok.
- Release render kapısı: Türkçe ve İngilizce 366 günün tüm stil/format kombinasyonlarında toplam 4.392 render başarıyla üretildi.
- Release arşivi: `build/WhaDay-1.1.0-b11.xcarchive`.
- Dağıtım IPA'sı: `build/export-1.1.0-b11/WhaDayNative.ipa`.
- IPA doğrulaması: sürüm `1.1.0`, build `11`, Apple Distribution imzası geçerli, `get-task-allow=false`, CloudKit ortamı `Production`.
- IPA SHA-256: `db7101dc09538b9da142984e57198b7f7a308e17fd5884a545f35bcdc6f3e3d3`.

## Yayın sınırı

Arşiv ve IPA yerelde hazırdır. App Store Connect'e yükleme, Apple tarafındaki işleme, TestFlight dağıtımı ve App Review gönderimi bu çalışma kapsamında yapılmadı; bunlar ayrı yayın adımlarıdır.
