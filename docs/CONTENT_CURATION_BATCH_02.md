# Content curation batch 02 — featured share cards

Date: 2026-08-14

## Outcome

- 42 previously hand-written featured cards were materialized into both localized catalogs.
- The app, widget and share renderer now consume the same reviewed facts and prompts instead of relying on a separate in-code copy island.
- Metadata was reviewed per record: official institutional dates, established cultural dates and WhaDay editorial prompts are now distinct.
- Six institutional dates in this batch carry checked UN/FAO provenance: Happiness, Bee, Tea, Friendship, Coffee and Toilet days.
- Content readiness moved from 50 to 92 curated records; unreviewed records fell from 316 to 274.

## Date correction: 29 February

Rare Disease Day is observed on the last day of February, not permanently on 29 February. A fixed month/day catalog cannot represent that rule correctly without a moving-observance layer. The stale `02-29` record was replaced with the explicitly editorial `Fazladan Gün` / `Bonus Day`, a shareable prompt that is valid whenever the date exists.

The audit and tests now reject Rare Disease Day, World Maritime Day, International Day of Cooperatives and World Day of Remembrance for Road Traffic Victims if they reappear as permanent fixed dates.

## Single source of reviewed copy

`scripts/materialize_featured_copy.swift` extracts the 42 featured facts and prompts from the hand-written `EditorialContent` dictionary and writes them to `tr.json` and `en.json`. It refuses to proceed unless it finds exactly 42 unique records. A bilingual test then asserts that every curated record renders the same fact and prompt stored in its localized corpus.

This is an intermediate migration step. Once all 366 records are curated, the remaining in-code featured dictionary can be removed and the localized corpus will be the only editorial source of truth.

## Remaining content work

- 274 records remain unreviewed.
- 249 generic descriptions remain in each locale.
- 198 default sharing hooks remain in each locale.
- The next batch targets the remaining high-shareability records, but first downgrades any health, violence, memorial or institutional day that the original generated metadata incorrectly labeled playful.
