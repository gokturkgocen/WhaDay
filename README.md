# WhaDay

Native iOS app (SwiftUI) for daily themed moments and shareable story cards, with a home-screen
WidgetKit widget.

## Development

Requires [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```sh
xcodegen generate
open WhaDay.xcodeproj
```

`WhaDay.xcodeproj` is generated from `project.yml` and is not checked in — never edit it directly;
edit `project.yml` and re-run `xcodegen generate` instead.

## Structure

- `WhaDayNative/` — main app target (SwiftUI)
- `WhaDayWidget/` — WidgetKit extension, synced with the app via an App Group
