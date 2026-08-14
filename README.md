# WhaDay

Native iOS app (SwiftUI) that turns each calendar day into a reason to text someone.

The app includes a daily card, a weekly shortlist of shareable days, an on-device
"send later" library, a source/status layer, one calm morning reminder, a WidgetKit widget,
and a Share Studio that produces channel-specific message and Story cards in three visual
styles. It does not request contact access or require an account.

## Development

Requires [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```sh
xcodegen generate
open WhaDay.xcodeproj
```

`WhaDay.xcodeproj` is generated from `project.yml` and is not checked in — never edit it directly;
edit `project.yml` and re-run `xcodegen generate` instead.

The binding 1.0 product scope and completion gates are documented in
[`docs/PRODUCT_CONTRACT.md`](docs/PRODUCT_CONTRACT.md). Implementation progress
is tracked in [`docs/DEVELOPMENT_ROADMAP.md`](docs/DEVELOPMENT_ROADMAP.md), and
the latest simulator-qualified candidate is recorded in
[`docs/DEVELOPMENT_RC_EVIDENCE.md`](docs/DEVELOPMENT_RC_EVIDENCE.md).

Run the strict editorial gate before treating a content revision as a release
candidate:

```sh
swift scripts/audit_content.swift --strict
```

## Structure

- `WhaDayNative/` — main app target (SwiftUI)
- `WhaDayWidget/` — WidgetKit extension, synced with the app via an App Group
- `WhaDayNativeTests/` — editorial, provenance and share-rendering quality gates
