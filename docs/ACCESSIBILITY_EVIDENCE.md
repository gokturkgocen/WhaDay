# Accessibility Evidence

Date: 2026-08-14  
Scope: development-time simulator validation; physical-device VoiceOver remains open.

## Implemented behavior

- App typography now scales through a shared `appFont` modifier instead of fixed
  point sizes across Home, Discover, Settings, day context and Share Studio.
- Accessibility text sizes use a vertically scrollable Home composition so the
  day title, context, source action and Share Studio entry remain reachable.
- Compact date and eyebrow variants protect meaning without forcing long labels
  into narrow controls. The full sharing prompt remains in the accessibility
  label when the visible accessibility-size button title is shortened.
- Core buttons have a minimum 44×44 point hit target. Selected filters, formats
  and styles expose a selected state and add a non-color checkmark where useful.
- Decorative animation is disabled when Reduce Motion is enabled.
- Blurred/translucent decoration is removed or made opaque for Reduce
  Transparency. Increased Contrast removes background glows and strengthens
  card outlines.
- Share-card previews are presented as one described accessibility element;
  navigation, close, save, filter, reminder and sharing controls have explicit
  labels or values.

## Device and language matrix

| Device class | Simulator | Text setting | Languages | Result |
| --- | --- | --- | --- | --- |
| Compact | iPhone SE (3rd generation) | Accessibility XXXL + Increased Contrast | Turkish, English | 2/2 UI journeys passed; 8 screenshots inspected |
| Standard | iPhone 17 | Large | Turkish, English | 2/2 UI journeys passed; 8 screenshots inspected |
| Large | iPhone 17 Pro Max | XXXL | Turkish, English | 2/2 UI journeys passed; 8 screenshots inspected |

Each UI journey verifies that the top of Home renders, the Share Studio action
can be reached by scrolling, Share Studio opens with its primary action, it can
be dismissed, and Discover opens. Four screenshots are attached per language.

The compact Accessibility XXXL pass initially exposed broken branding, clipped
day content and an unreachable sharing action. The layout was changed and the
same two journeys then passed. The large-device pass later exposed truncated
style descriptions; expanded horizontal cards now preserve the complete copy.

## Combined regression run

Command:

```sh
xcodebuild test \
  -project WhaDay.xcodeproj \
  -scheme WhaDayNative \
  -destination 'platform=iOS Simulator,id=<iPhone 17 Pro Max>' \
  CODE_SIGNING_ALLOWED=NO
```

Result: `TEST SUCCEEDED`; 42 tests executed, 41 passed, 1 skipped, 0 failed.
The skipped test is the opt-in 4,392-render share matrix, whose successful full
run is recorded separately in `SHARE_MATRIX_EVIDENCE.md`.

## Honest remaining gate

Automated accessibility identifiers and screenshots do not prove a coherent
VoiceOver traversal. Before accessibility can be called fully complete, the
Home → day context → Share Studio → Discover journey must be completed with
VoiceOver on a physical device, checking focus order, rotor behavior and share
sheet handoff without sight.
