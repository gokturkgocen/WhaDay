# WhaDay 1.0 Development Roadmap

Status: Active  
Started: 2026-08-14

This roadmap stops at a development-complete release candidate. Distribution,
store submission and launch operations are deliberately excluded.

The binding product decisions and final quality bar live in
[`PRODUCT_CONTRACT.md`](PRODUCT_CONTRACT.md).

## Phase 0 — Product contract

- [x] Lock the product promise and privacy posture.
- [x] Lock 1.0 scope and explicit non-goals.
- [x] Define measurable completion gates.

Exit: the contract can reject attractive but distracting feature work.

## Phase 1 — Editorial content system

- [x] Move authority, source, sensitivity and review state into data.
- [x] Replace the broad legacy category model with a typed twelve-part taxonomy.
- [ ] Review all 366 dates for fixed-date validity and cultural scope.
- [ ] Rewrite Turkish content as native copy.
- [ ] Adapt English content by intent rather than literal translation.
- [ ] Attach primary sources to every official claim.
- [ ] Remove visible dependence on generic fallback copy.
- [x] Add corpus-wide integrity, safety and length tests.

Exit: every date is independently trustworthy and shareable.

## Phase 2 — Date and routing foundation

- [x] Add one typed route model for home, day, discovery, settings and share.
- [x] Add event deep links and cold/warm launch routing.
- [x] Route notification and widget taps to the displayed event.
- [x] Refresh the active date at midnight and after time-zone changes.
- [x] Inject clock, calendar and locale dependencies for boundary tests.
- [x] Preserve selection across navigation and app lifecycle transitions.

Exit: every entry surface resolves to the same correct day.

## Phase 3 — First-use and discovery

- [ ] Add a dismissible, contextual three-step first-use coach.
- [ ] Request notification permission only after demonstrated value.
- [ ] Add lightweight title search and five high-signal filters.
- [ ] Expand saved dates beyond the current preview list.
- [ ] Make weekly picks diverse, deterministic and sensitivity-aware.
- [ ] Test weekly selection across every start date in a full year.

Exit: a first-time user understands and reaches sharing without instruction.

## Phase 4 — Save and reminder loop

- [ ] Separate the in-app reminder preference from system authorization.
- [ ] Add a user-selected reminder time and an Open Settings recovery action.
- [ ] Merge saved-day context into one calm daily notification.
- [ ] Prevent duplicate requests and respect the system pending-request limit.
- [ ] Replan safely after clock, time-zone, locale and content changes.
- [ ] Test denied, revoked, long-absence and multiple-saved-day scenarios.

Exit: reminders are useful, user-controlled and always open the right content.

## Phase 5 — Share Studio

- [ ] Give Editorial, Playful and Minimal styles distinct visual jobs.
- [ ] Refine separate 1080×1920 Story and 1080×1350 Message compositions.
- [ ] Add long-title, sensitive-day and safe-area layout behavior.
- [ ] Keep WhaDay attribution subtle and personal captions non-promotional.
- [ ] Harden Instagram fallback and system share-sheet payloads.
- [ ] Render and validate the full 4,392-image locale/style/format matrix.
- [ ] Verify Instagram, WhatsApp and Messages on a physical device.

Exit: every event produces artwork worth sending in its intended channel.

## Phase 6 — Widgets

- [ ] Make widget data available before a prior app launch.
- [x] Add exact-event deep links.
- [ ] Correct midnight timeline refresh and locale behavior.
- [ ] Add a Lock Screen accessory rectangular family.
- [ ] Remove playful fixed labels from sensitive entries.
- [ ] Add VoiceOver labels and graceful corruption fallback.

Exit: widgets remain correct and useful independently of the app process.

## Phase 7 — Accessibility and device matrix

- [ ] Support all Dynamic Type sizes without losing core information.
- [ ] Complete VoiceOver labels, grouping, order and state announcements.
- [ ] Honor Reduce Motion, Increase Contrast and Reduce Transparency.
- [ ] Enforce 44-point targets and avoid color-only state.
- [ ] Test compact, standard and large iPhones in both languages.
- [ ] Complete the core journey without sight.

Exit: accessibility is a supported experience, not a launch exception list.

## Phase 8 — Reliability and performance

- [ ] Add content, route, notification, persistence and widget test suites.
- [ ] Add date-boundary and lifecycle integration coverage.
- [ ] Add localized UI smoke tests and share-render failure handling.
- [ ] Recover safely from malformed on-device data.
- [ ] Measure launch, scrolling, render time and memory regressions.
- [ ] Remove project-owned compiler warnings.

Exit: the same revision passes functional, visual and performance gates.

## Phase 9 — Development quality gate

- [ ] Execute the complete simulator scenario matrix.
- [ ] Execute notification, widget and sharing scenarios on a physical device.
- [ ] Clear every P0 and P1 defect.
- [ ] Record P2 decisions without hiding them.
- [ ] Produce a final evidence report tied to the tested revision.

Exit: every item in `PRODUCT_CONTRACT.md`'s definition of done is evidenced.

## Working protocol

- Complete phases in dependency order; do not postpone content or
  accessibility debt until the last visual pass.
- Use focused commits whose message names the closed capability.
- Every phase closes with build/tests plus the relevant visual or device check.
- A green automated test does not substitute for required visual inspection.
- If an external app or physical-device state is temporarily unavailable, keep
  implementing independent work and record the unmet gate explicitly.
