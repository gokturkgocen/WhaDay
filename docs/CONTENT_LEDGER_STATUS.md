# WhaDay Content Ledger Status

Snapshot date: 2026-08-14  
Dataset: `WhaDayNative/Data/metadata.json`

This file records progress, not completion. The locale-neutral ledger is now
structurally complete, but inferred bootstrap values remain a manual review
queue. A `source-linked` record has an institutional source attached; only a
future `verified` state means its exact date, title, scope and source have been
individually checked.

## Structural result

- Metadata records: 366
- Missing localized IDs: 0
- Duplicate metadata IDs: 0
- Official authority records without a source: 0
- Legacy bell symbols exposed through metadata: 0
- Typed content categories: 12

## Authority queue

| Authority | Count | Meaning at this stage |
| --- | ---: | --- |
| Official | 40 | An institutional calendar source is attached; exact-entry verification remains required. |
| Cultural | 41 | A tradition, faith or country-specific scope was inferred and must be reviewed. |
| Editorial | 285 | No official status is claimed; title, date and social fit still require review. |

## Safety queue

| Sensitivity | Count | Promotion behavior |
| --- | ---: | --- |
| Standard | 319 | Eligible only after editorial review and shareability scoring. |
| Considerate | 17 | Excluded from engagement-driven weekly promotion. |
| Remembrance | 30 | Excluded from engagement promotion and rendered as a note, never an excuse. |

## Review queue

| Review state | Count |
| --- | ---: |
| Needs editorial review | 287 |
| Needs safety review | 47 |
| Source linked | 32 |
| Curated | 0 |
| Verified | 0 |

## Taxonomy distribution

| Category | Count |
| --- | ---: |
| Playful | 165 |
| Celebrations | 40 |
| Remembrance | 30 |
| Animals and nature | 25 |
| Culture and arts | 21 |
| Civil society | 20 |
| Health and awareness | 17 |
| Food and drink | 16 |
| Science and curiosity | 13 |
| Relationships | 9 |
| Sport and movement | 7 |
| Professions | 3 |

The old 272-entry `awareness` bucket no longer drives the app. The current
`playful` bucket is still too broad and is explicitly part of manual review;
the bootstrap script must not be treated as final editorial judgment.

## Enforcement now active

The app and tests now require:

- one locale-neutral metadata record for every localized day;
- valid 1–5 shareability values;
- a non-empty non-bell symbol;
- an HTTPS source for every official authority record;
- non-promotional behavior for considerate and remembrance records; and
- no single taxonomy bucket containing a majority of the calendar.

The bootstrap script refuses to overwrite the ledger unless explicitly run
with `--force`. Once manual review begins, edits belong in the ledger rather
than in title-based inference rules.
