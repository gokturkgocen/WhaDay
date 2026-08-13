---
description: Mac geliştirme ortamı temizliği - Xcode cache, CocoaPods ve npm temizleme
---

// turbo-all

## Ne zaman uygulanacak?
- Her büyük `pod install` veya `npx expo prebuild` işleminden sonra
- Build hataları yaşandığında (temiz slate)
- Disk dolmaya başladığında

## 1. Xcode DerivedData Temizle (en büyük şişman, 10-30 GB)
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

## 2. iOS Simulator Cache Temizle
```bash
rm -rf ~/Library/Developer/CoreSimulator/Caches
```

## 3. CocoaPods Cache Temizle
```bash
/opt/homebrew/lib/ruby/gems/4.0.0/bin/pod cache clean --all
rm -rf ~/Library/Caches/CocoaPods
```

## 4. npm Cache Temizle
```bash
npm cache clean --force
```

## 5. Genel macOS Cache Temizle
```bash
rm -rf ~/Library/Caches/com.apple.dt.Xcode
```

## Notlar
- `node_modules` silinirse `npm install` ile yeniden kurulur
- `ios/` klasörü silinirse `npx expo prebuild --platform ios` ile yeniden oluşturulur
- Bu komutlar tamamen güvenlidir, proje dosyalarına dokunmaz
