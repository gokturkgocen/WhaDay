# App Store Screenshots

The checked-in JPG files are the final 6.9-inch App Store assets at 1320 × 2868. They are generated from real 1206 × 2622 iPhone 17 simulator captures, not reconstructed UI mockups.

## Generate Turkish

```sh
swift scripts/generate_store_screenshots.swift \
  marketing/app-store/raw/tr-TR \
  marketing/app-store/tr-TR \
  tr
```

## Generate English

```sh
swift scripts/generate_store_screenshots.swift \
  marketing/app-store/raw/en-US \
  marketing/app-store/en-US \
  en
```

Every asset must be visually inspected after generation. In particular, confirm that headlines do not collide with the phone frame, long localized titles are not clipped in a misleading way, and the screen reflects the exact release candidate.
