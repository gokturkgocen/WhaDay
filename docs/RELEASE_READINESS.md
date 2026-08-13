# WhaDay 1.0 Release Readiness

Last updated: 2026-08-13

This file separates source completion from device, TestFlight and public-release gates. A successful local build is not a published app.

## Verified locally

- Native SwiftUI app and WidgetKit extension build for a generic iOS device.
- Editorial/share suite passes all 16 tests.
- Daily card, weekly picks, saved days, calendar and Share Studio were exercised in an iPhone 17 simulator.
- Turkish App Store metadata and a five-image 1320 × 2868 screenshot set match the current product.
- App privacy manifest declares UserDefaults access, no tracking and no collected data.
- Support and privacy pages are live over HTTPS and return HTTP 200:
  - `https://gokturkgocen.github.io/WhaDay/support/`
  - `https://gokturkgocen.github.io/WhaDay/privacy/`

## Required before archive

- Run VoiceOver, Dynamic Type and Reduce Motion checks on the release candidate.
- Verify layouts on one compact iPhone size and one current large iPhone size.
- Exercise save/restore, foreground date rollover and notification rescheduling after relaunch.
- Test Story handoff with Instagram installed and 4:5 sharing with WhatsApp installed on a physical device.
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
