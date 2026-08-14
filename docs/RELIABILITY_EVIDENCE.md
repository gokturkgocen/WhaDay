# Reliability and Performance Evidence

Date: 2026-08-14  
Simulator: iPhone 17, iOS 26.5, standard text size  
Scope: local development candidate; performance values are simulator baselines,
not physical-device launch claims.

## Recovery behavior

- Saved-day persistence accepts only IDs present in the bundled 366-day
  catalog, removes duplicates and unknown IDs, and rewrites malformed storage
  to a safe canonical array.
- Reminder preferences recover from wrong value types and clamp hours to
  `0...23` and minutes to `0...59`. The reminder planner repeats that clamp so
  invalid direct configurations cannot let `Calendar` normalize into a
  different date.
- A stale route request cannot consume a newer request. Invalid external URLs
  leave the current valid request untouched.
- Date context refresh updates the instant, calendar/time zone and locale as
  one state transition; the resulting event ID and next boundary are covered.

## Same-revision regression run

Command:

```sh
xcodebuild test \
  -project WhaDay.xcodeproj \
  -scheme WhaDayNative \
  -destination 'platform=iOS Simulator,id=<iPhone 17>' \
  CODE_SIGNING_ALLOWED=NO
```

Result: `TEST SUCCEEDED`.

| Target | Executed | Passed | Skipped | Failed |
| --- | ---: | ---: | ---: | ---: |
| Unit, integration and render tests | 48 | 47 | 1 | 0 |
| Localized accessibility and performance UI tests | 4 | 4 | 0 | 0 |
| Total | 52 | 51 | 1 | 0 |

The single opt-in skip is the 4,392-render share matrix. Its full successful
release-candidate run is recorded in `SHARE_MATRIX_EVIDENCE.md`.

Covered suites include editorial/content integrity, routing, date/time-zone and
DST boundaries, reminders, persistence, widgets, full-year discovery
selection, malformed data recovery, share rendering, Turkish/English UI smoke
journeys and performance metrics.

## Performance baseline

Measured during the same complete run:

| Workload | Mean | Peak physical memory |
| --- | ---: | ---: |
| Decode 366 Turkish catalog records | 0.001 s | 45.2 MB |
| Run 600 localized discovery queries | 0.291 s | 58.6 MB |
| Render one 1080×1350 Editorial message card | 0.002 s | 48.2 MB |
| Responsive first-frame launch | 1.290 s | — |
| Calendar scroll deceleration signpost | 2.433 s | — |

These measurements establish a reproducible simulator baseline. Xcode records
the raw iterations in the result bundle; physical-device performance remains a
final quality-gate check because simulator timings are not user-facing device
guarantees.

## Warning audit

A clean `build-for-testing` produced zero WhaDay Swift compiler warnings. Xcode
17.6 still emits one build-tool warning while processing the UI-test bundle:
`Metadata extraction skipped. No AppIntents.framework dependency found.` The
UI-test target does not use App Intents; adding an unused production dependency
solely to suppress that Xcode metadata-processor message would be misleading.
It is recorded as toolchain output, not hidden or counted as a project-owned
compiler warning.
