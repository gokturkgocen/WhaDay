# WhaDay 1.0 Development RC Evidence

Date: 2026-08-14  
Tested app/content revision: `5d78bd0`  
Status: Simulator-qualified candidate; physical-device gates remain open.

This report stops at development readiness. It does not claim archive,
TestFlight, App Store or public-release completion.

## Product and content

- 366 Turkish records, 366 English records and 366 metadata records.
- Every record is individually classified and marked `curated`.
- Every official record has an HTTPS source and a `2026-08-14` review date.
- Zero generic legacy descriptions and zero default sharing hooks.
- Zero structural issues and zero semantic safety issues.
- `swift scripts/audit_content.swift --strict` exits successfully.
- Moving observances found on fixed dates were replaced with transparent
  WhaDay prompts or corrected to their current official date.

## Automated and simulator evidence

| Gate | Result |
| --- | --- |
| Unit, integration, routing, notification, persistence and widget suite | 53/53 passed |
| Full two-locale, three-style, two-format share matrix | 4,392/4,392 rendered |
| iPhone 17 Turkish and English core journey | 2/2 passed |
| iPhone 17 UI performance scenarios | 2/2 passed |
| iPhone SE Accessibility XXXL + Increased Contrast | 2/2 passed |
| iPhone 17 Pro Max XXXL | 2/2 passed |
| Compiler warnings owned by WhaDay | 0 |

The matrix test rendered each 1080×1920 Story and 1080×1350 Message image at
the exact expected dimensions. Current-revision screenshots were attached for
Home, the reachable share action, Share Studio and Discovery in both languages
on all three device classes. Representative standard and compact captures were
manually inspected.

## Known defects and decisions

- No P0 or P1 defect is known in the automated and simulator-tested scope.
- No app-owned P2 defect is being hidden or accepted for 1.0 at this point.
- Xcode emits an App Intents metadata message for the UI-test bundle even
  though that target does not use App Intents. This is recorded as toolchain
  output, not suppressed by adding a false production dependency.
- Single-line ellipsis on secondary Discovery summaries at extreme text sizes
  is intentional; the full prompt remains in accessibility output and the
  primary journey remains scrollable and reachable.

## Physical-device gates still required

Development must not be called complete until these checks pass on the actual
release candidate:

1. Complete Home → context → Share Studio → Discover with VoiceOver and without
   relying on sight; verify focus order, state announcements and rotor behavior.
2. Deliver Story artwork to Instagram and Message artwork to WhatsApp and
   Messages, then verify the received image and fallback paths.
3. Exercise notification permission grant, denial/recovery, scheduled tap and
   widget tap on device; each must open the exact displayed event.
4. Record physical-device launch, scrolling and share-render observations.

These are external device gates, not inferred passes. Until they are executed,
the honest label is **simulator-qualified development candidate**, not “finished.”
