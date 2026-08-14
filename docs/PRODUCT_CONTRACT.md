# WhaDay Product Contract

Status: Development authority for WhaDay 1.0  
Last updated: 2026-08-14

## Product promise

WhaDay turns today's calendar note into a small act of connection:

1. See what today is.
2. Understand why it belongs on the calendar.
3. Think of one person.
4. Send a beautiful, channel-ready card.
5. Return tomorrow without pressure.

The shortest version is **see, remember, send, return**. A proposed feature must
make at least one of those verbs meaningfully better without weakening the
others.

## Product principles

### Trust before volume

WhaDay does not compete on the number of observances. Every day must clearly be
described as an official observance, a cultural calendar date or a playful
WhaDay editorial prompt. Official status is never implied without a primary
source.

### A person, not an audience

The main question is not “what can I post?” but “who did this make me think
of?” Sharing should feel like a natural message to one person even when the
same artwork also works in a Story.

### One calm daily ritual

The app has one primary card and one optional daily reminder. It does not use
streak anxiety, engagement bait or notification volume to manufacture habit.

### Channel-native beauty

Message and Story artwork are distinct outputs, not a single design cropped to
two aspect ratios. Long titles, sensitive observances and accessibility sizes
are part of the design system rather than exceptions handled at the end.

### Private by default

The core product works without an account, contact access, analytics SDK,
social graph or network connection. Sharing happens through user-initiated
system surfaces.

## WhaDay 1.0 scope

- One localized event for every calendar date, including February 29
- Turkish and English editorial content
- Transparent authority and source context
- Daily card, full calendar, lightweight search and weekly discovery
- On-device saved-day library
- One user-controlled daily reminder
- Small, medium and Lock Screen daily widgets
- Message and Story share artwork in three visual styles
- Instagram Story, WhatsApp, Messages and system share-sheet handoff
- Dynamic Type, Reduce Motion and baseline screen-reader labeling
- Offline-first operation

## Explicitly out of scope for 1.0

- Accounts, profiles and cloud sync
- Contact permission or an in-app friend graph
- Feed, comments, likes or direct messages
- User-created calendar dates and calendar import
- Streaks, points, badges and competitive gamification
- Subscriptions, paywalls and advertising
- Remote AI-generated daily content
- Android, iPad, macOS, watchOS and Live Activities
- More languages beyond Turkish and English

These are not rejected forever. They are excluded because they do not need to
exist for the core promise to feel complete.

## Core experience budgets

- Today's card is understandable without onboarding.
- The system share sheet is reachable from the home card in no more than three
  meaningful taps.
- No permission prompt appears before the user sees product value.
- A saved day, notification and widget always resolve to the same event ID.
- The app never describes an editorial prompt as official.
- Sensitive and remembrance dates never use “excuse”, joke or guilt language.

## Development definition of done

Development is complete only when all of these statements are true on the same
revision:

- All 366 dates are individually classified, reviewed and localized.
- Every official entry has an attached primary source and review date.
- No visible event depends on generic legacy or semantic fallback copy.
- Every notification and widget path opens the exact event it displayed.
- Every combination of 366 dates, two languages, three share styles and two
  formats renders without clipping or missing content.
- The core flow passes on a compact and a large supported iPhone.
- The core flow is completable at accessibility text sizes.
- Reduce Motion stops continuous and large decorative movement.
- Leap-day, year-boundary, midnight, time-zone and daylight-saving tests pass.
- Real-device Instagram Story, WhatsApp and Messages handoffs pass.
- There are no known P0 or P1 defects and no compiler warnings owned by WhaDay.
- The evidence report includes automated results and visual/device checks, not
  only a successful build.

Market fit is not part of this technical claim. “Development complete” means
the product promise is implemented honestly and robustly; it does not claim
that real-world retention or sharing behavior has already been proven.
