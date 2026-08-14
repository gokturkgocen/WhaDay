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

## Current release-candidate regression

Command:

```sh
xcodebuild test \
  -project WhaDay.xcodeproj \
  -scheme WhaDayNative \
  -destination 'platform=iOS Simulator,id=<iPhone 17>' \
  CODE_SIGNING_ALLOWED=NO
```

Tested app/content revision: `e149f0b`. Result: `TEST SUCCEEDED` in every
operation.

| Operation | Executed | Passed | Skipped | Failed |
| --- | ---: | ---: | ---: | ---: |
| Unit, integration, reliability and full render matrix | 54 | 54 | 0 | 0 |
| iPhone 17 localized accessibility and performance UI | 4 | 4 | 0 | 0 |
| iPhone SE Accessibility XXXL + Increased Contrast journeys | 2 | 2 | 0 | 0 |
| iPhone 17 Pro Max XXXL journeys | 2 | 2 | 0 | 0 |
| Total scenario invocations | 62 | 62 | 0 | 0 |

The opt-in 4,392-render gate was enabled for this run, so no test was skipped.
Its detailed result is recorded in `SHARE_MATRIX_EVIDENCE.md`.

Covered suites include editorial/content integrity, routing, date/time-zone and
DST boundaries, reminders, persistence, widgets, full-year discovery
selection, malformed data recovery, share rendering, Turkish/English UI smoke
journeys and performance metrics.

## Performance baseline

Measured during the same complete run:

| Workload | Mean | Peak physical memory |
| --- | ---: | ---: |
| Decode 366 Turkish catalog records | 0.002 s | 32.9 MB |
| Run 600 localized discovery queries | 0.642 s | 45.3 MB |
| Render one 1080×1350 Editorial message card | 0.005 s | 35.7 MB |
| Responsive first-frame launch | 2.846 s | — |
| Calendar scroll deceleration signpost | 2.432 s | — |

The unit workloads were measured in an isolated test process on iPhone 17 after
the matrix run; launch and scroll were measured on the same simulator class.
These values are conservative simulator baselines, not user-facing
physical-device performance claims.

## Warning audit

A clean `build-for-testing` produced zero WhaDay Swift compiler warnings. Xcode
17.6 still emits one build-tool warning while processing the UI-test bundle:
`Metadata extraction skipped. No AppIntents.framework dependency found.` The
UI-test target does not use App Intents; adding an unused production dependency
solely to suppress that Xcode metadata-processor message would be misleading.
It is recorded as toolchain output, not hidden or counted as a project-owned
compiler warning.
