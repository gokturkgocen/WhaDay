# WhaDay 1.0 Release Readiness

Last updated: 2026-08-17

This file separates development readiness from archive, TestFlight and
public-release gates. Distribution work is outside the current development
plan; a successful local build is not a published app.

## Verified locally

- Native SwiftUI app and WidgetKit extension build for a generic iOS device.
- All 366 Turkish and English records pass the strict content audit with no
  generic copy, unreviewed records or semantic safety issues.
- Unit, integration, reliability and performance suites pass all 56 executed
  tests with one intentional skip for the separately verified full-render
  matrix.
- All 4,392 date, language, style and output-format combinations render at the
  exact expected dimensions.
- The bilingual Home → Share Studio → Discover journey passes on compact,
  standard and large simulator classes, including Accessibility XXXL and
  Increased Contrast.
- Turkish App Store metadata is current. Four 1320 × 2868 screenshots (`01`-`04`)
  are regenerated against the ivory release candidate; the fifth slot is held
  back because the only Settings framing available exposes a simulator StoreKit
  price rather than the real App Store price.
- WhaDay's privacy manifest declares its local UserDefaults access and nothing
  else. No advertising or attribution SDK is linked, so App Privacy is answered
  as "Data Not Collected". Verified by inspecting the Release `.app`: no
  GoogleMobileAds or UserMessagingPlatform framework is embedded.
- Support and privacy pages are live over HTTPS and return HTTP 200:
  - `https://gokturkgocen.github.io/WhaDay/support/`
  - `https://gokturkgocen.github.io/WhaDay/privacy/`

## Required before development-complete

- Test Story handoff with Instagram installed and Message handoff with WhatsApp
  and Messages installed on a physical device; inspect the received artwork and
  fallback paths.
- Exercise notification grant, denial/recovery, notification tap and widget tap
  on a physical device; each route must open the exact displayed event.
- Record physical-device launch, scrolling and share-render observations.

The tested revision and exact evidence are recorded in
[`DEVELOPMENT_RC_EVIDENCE.md`](DEVELOPMENT_RC_EVIDENCE.md).

## Required before archive

- Confirm App Group `group.com.gokturkgocen.whadayapp` is attached to both distribution App IDs and profiles.
- Resolve the generic-device orientation warning or explicitly require full-screen portrait behavior.
- Create the non-consumable WhaDay+ product with ID
  `com.gokturkgocen.whaday.plus.lifetime` and confirm its final localized price.

## App Store Connect gates

- Confirm or create the WhaDay app record, SKU, bundle ID and primary language.
- Enter the verified support and privacy URLs in App Store Connect.
- Complete App Privacy answers so they match `PrivacyInfo.xcprivacy` and actual behavior.
- Add Turkish metadata and screenshots; prepare English screenshots before enabling English storefront copy.
- Archive with the distribution identity, validate, upload and wait for processing to complete.
- Attach the processed build to an external TestFlight group and verify the public link if one is enabled.
- Complete TestFlight checks on a real device before selecting the build for review.

## Public release gates

- Submit review notes that describe local content, optional notifications, App Group data and user-initiated sharing.
- Verify the exact build reaches the intended App Store status; upload success alone is not release success.
- After release, verify the public product page and storefront availability separately.
