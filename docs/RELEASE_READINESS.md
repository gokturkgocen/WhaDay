# WhaDay 1.0 Release Readiness

Last updated: 2026-08-14

This file separates development readiness from archive, TestFlight and
public-release gates. Distribution work is outside the current development
plan; a successful local build is not a published app.

## Verified locally

- Native SwiftUI app and WidgetKit extension build for a generic iOS device.
- All 366 Turkish and English records pass the strict content audit with no
  generic copy, unreviewed records or semantic safety issues.
- Unit, integration, reliability, performance and full-render suite passes all
  53 tests with no skips.
- All 4,392 date, language, style and output-format combinations render at the
  exact expected dimensions.
- The bilingual Home → Share Studio → Discover journey passes on compact,
  standard and large simulator classes, including Accessibility XXXL and
  Increased Contrast.
- Turkish App Store metadata and a five-image 1320 × 2868 screenshot set match the current product.
- App privacy manifest declares UserDefaults access, no tracking and no collected data.
- Support and privacy pages are live over HTTPS and return HTTP 200:
  - `https://gokturkgocen.github.io/WhaDay/support/`
  - `https://gokturkgocen.github.io/WhaDay/privacy/`

## Required before development-complete

- Complete the core journey with VoiceOver on a physical device and verify
  focus order, announcements and rotor behavior without relying on sight.
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
