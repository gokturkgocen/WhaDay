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

## Current asset set

Only `01`–`04` are upload-ready. The fifth slot (`05-her-sabah-surpriz.jpg`) is
intentionally absent: it frames the Settings screen, whose WhaDay+ row renders
`purchaseStore.displayPrice`, and the simulator's StoreKit test environment
reports a price that is not the real localized App Store price. The Settings
content is too short to scroll that row out of frame. Re-shoot the fifth asset
only after the final WhaDay+ price exists in App Store Connect, or reframe the
slot onto a screen that carries no price.
