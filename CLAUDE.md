# WhaDay — Project Instructions

Native SwiftUI iPhone app that turns each calendar date into a reason to text
someone: a daily editorial card, weekly discovery, an on-device saved-day
library, one calm morning reminder, a WidgetKit widget, and a Share Studio that
renders channel-specific Message and Story artwork. No account, no contact
access, no advertising, offline-first. A one-time WhaDay+ purchase unlocks two
extra share appearances.

Work happens on the `native-swiftui` branch, which is 44 commits ahead of
`main` and has never been merged — `main` is still the abandoned React Native
migration. Do not treat `main` as current.

## Authority chain — read before proposing features

- [`docs/PRODUCT_CONTRACT.md`](docs/PRODUCT_CONTRACT.md) is **binding**: product
  promise, principles, 1.0 scope, explicit non-goals, completion gates. It
  exists to reject attractive but distracting work. Do not re-litigate a
  non-goal listed there; if something must change, say so explicitly and get a
  decision.
- [`docs/DEVELOPMENT_ROADMAP.md`](docs/DEVELOPMENT_ROADMAP.md) — phase-by-phase
  progress with checkboxes. Phases 0–8 are closed; 9 and 10 have open items.
- [`docs/RELEASE_READINESS.md`](docs/RELEASE_READINESS.md) — separates
  development readiness from archive/TestFlight/public-release gates. This is
  the list of what is actually left.
- [`docs/DEVELOPMENT_RC_EVIDENCE.md`](docs/DEVELOPMENT_RC_EVIDENCE.md) — the
  simulator-qualified candidate and its measured evidence.
- [`docs/CONTENT_POLICY.md`](docs/CONTENT_POLICY.md) — editorial rules for the
  366-date corpus.
- [`docs/POST_1_0_BACKLOG.md`](docs/POST_1_0_BACKLOG.md) — intended post-1.0
  direction. Nothing there may be implemented before the 1.0 RC closes.

## Commands

Project generation (required after any structural change):

```bash
xcodegen generate
```

Content gate — run before treating any content revision as a candidate:

```bash
swift scripts/audit_content.swift --strict
```

Simulator build:

```bash
xcodebuild -scheme WhaDayNative -configuration Debug -derivedDataPath /Volumes/X9/Caches.noindex/WhaDay -destination 'generic/platform=iOS Simulator' build
```

Physical device build, then install (`GG`, udid `00008140-000104193478801C`):

```bash
xcodebuild -scheme WhaDayNative -configuration Debug -derivedDataPath /Volumes/X9/Caches.noindex/WhaDay -destination 'id=00008140-000104193478801C' build
```

```bash
xcrun devicectl device install app --device 00008140-000104193478801C /Volumes/X9/Caches.noindex/WhaDay/Build/Products/Debug-iphoneos/WhaDayNative.app
```

## Architecture

- **`project.yml` + xcodegen is the single source of truth.** `WhaDay.xcodeproj`
  is generated and gitignored — never edit it.
- Four targets: `WhaDayNative` (app), `WhaDayWidgetExtension`,
  `WhaDayNativeTests`, `WhaDayNativeUITests`. Bundle ids
  `com.gokturkgocen.whadayapp` and `…whadayapp.WhaDayWidget`.
- iOS 17.0 minimum, Swift 6, iPhone only (`TARGETED_DEVICE_FAMILY: "1"`),
  portrait-only with `UIRequiresFullScreen`.
- Signing is real Apple Developer signing, `DEVELOPMENT_TEAM: 3R9ULKMUXY`.
- App and widget share `group.com.gokturkgocen.whadayapp` (App Group) plus the
  `Shared/` source folder (`WidgetDayCatalog.swift`). `WidgetDataWriter` writes
  the shared `UserDefaults` and calls `WidgetCenter.reloadTimelines(ofKind:)`
  directly.
- **Content layer**: `Data/tr.json`, `Data/en.json` (366 records each, including
  `02-29`) and `Data/metadata.json` (366 classification records: authority,
  category, sensitivity, shareability, scope, audience, reviewState).
  `DayEventStore` loads the locale's records and merges metadata by id via
  `DayEvent.attaching(_:)`; typed accessors (`contentCategory`, `authority`,
  `sensitivity`, `shareability`) fall back to legacy fields when metadata is
  absent. Language is derived from `Locale.preferredLanguages`, not a user
  setting.
- **Monetization**: StoreKit 2, one non-consumable
  `com.gokturkgocen.whaday.plus.lifetime` (`PurchaseStore`), editorial paywall
  shown only after explicit intent (`PlusPaywallView`). It unlocks the Graphite
  and Tone share appearances and nothing else. Price decided at ₺74.99 base
  (Turkey); rationale in `docs/APP_STORE_ANSWERS.md`.
- **No advertising.** 1.0 ships with no ad, attribution or analytics SDK. The
  consent-gated Google native ad was built and then deliberately removed so
  App Privacy can honestly answer "Data Not Collected"; the implementation
  survives in git history (see the commit removing `WhaDayNative/Advertising/`)
  if it is ever revived. Do not reintroduce it without revisiting
  `docs/PRODUCT_CONTRACT.md`, the public privacy page and App Privacy.
- Ambient/editorial backgrounds compute every element's phase as a pure trig
  function of one shared elapsed time under a single `TimelineView(.animation)`
  — no per-element animation state.
- Share artwork is `ImageRenderer` → `ShareLink`, three styles (Ivory free,
  Graphite and Tone in WhaDay+), two formats (1080×1920 Story, 1080×1350
  Message).
- Notifications use a rolling ~30-day window, because iOS caps pending local
  notifications at 64/app and the corpus covers a full year.

## Conventions and traps

- Adding a data file the widget needs means adding it to the widget target's
  `sources` as a `resources` build phase in `project.yml` — the widget bundles
  `tr.json`, `en.json` and `metadata.json` explicitly.
- Turkish is authored as native copy and English is adapted by intent, not
  translated literally. No translation markers, no generic fallback copy, no
  default sharing hooks — `audit_content.swift --strict` fails on all of these.
- `xcodebuild … install` reports `INSTALL SUCCEEDED` after writing to
  `InstallationBuildProductsLocation` — that is not the device. Install with
  `xcrun devicectl device install app`.
- Always pass an explicit `-destination`. Without one, xcodebuild picks the Mac
  and fails with a provisioning-profile error naming the MacBook, which reads
  like a signing problem rather than a wrong-destination problem.
- Xcode may list other people's connected devices. The user's iPhone is `GG`
  (`00008140-000104193478801C`); anything else in the list is not his.
- Derived data goes to `/Volumes/X9/Caches.noindex/WhaDay`, never `/tmp`.
- Physical device is the real verification surface; a simulator pass is a quick
  check, not the gate.

## Open items

- Physical-device gates remain open: Instagram/WhatsApp/Messages handoff,
  notification grant/denial/tap and widget tap routing, and device launch and
  scroll observations. See `docs/RELEASE_READINESS.md`.
- StoreKit sandbox validation (purchase, restore, Ask to Buy, refund/revocation)
  not yet run. The WhaDay+ product does not exist in App Store Connect yet.
- App Store Connect answer sheet (App Privacy, export compliance, age rating,
  review notes) is written out in `docs/APP_STORE_ANSWERS.md` and still needs to
  be entered by hand.
- `LICENSE` is self-contradictory — MIT text at the top, "kopyalanması yasak" /
  "all rights reserved" at the bottom — and the repo is public on GitHub. Needs
  a decision, not a patch.

## Post-1.0 direction

The next intended capability is the **sealed personal day**: a user-authored day
with one attached recipient, invisible to that recipient until its date, revealed
to both sides on the date, and undeletable while sealed except for WhaDay+ users.
It contradicts five committed 1.0 non-goals and its two defining rules cannot be
enforced without a backend. The client-only-vs-backend decision precedes any
implementation. Full write-up in
[`docs/POST_1_0_BACKLOG.md`](docs/POST_1_0_BACKLOG.md).
