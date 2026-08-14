# WhaDay Content Ledger Status

Snapshot date: 2026-08-14  
Dataset: `WhaDayNative/Data/metadata.json`

The locale-neutral ledger and both localized corpora have completed the 1.0
editorial gate. Source verification and editorial review remain deliberately independent:
`source.checkedAt` records an exact date/title/source check, while `reviewState`
records whether the user-facing copy has completed editorial or safety review.

## Structural result

- Metadata records: 366
- Missing localized IDs: 0
- Duplicate metadata IDs: 0
- Official authority records without a source: 0
- Source records verified on 2026-08-14: 250
- Legacy bell symbols exposed through metadata: 0
- Typed content categories: 12

## Authority queue

| Authority | Count | Meaning at this stage |
| --- | ---: | --- |
| Official | 180 | Every official claim has a source and review date. |
| Cultural | 120 | Faith, national and movement-origin dates name their cultural scope. |
| Editorial | 66 | WhaDay-created prompts explicitly use `whaday-editorial` scope. |

## Safety queue

| Sensitivity | Count | Promotion behavior |
| --- | ---: | --- |
| Standard | 270 | Eligible according to reviewed shareability and category. |
| Considerate | 71 | Excluded from engagement-driven weekly promotion. |
| Remembrance | 25 | Excluded from engagement promotion and rendered as a note, never an excuse. |

## Review queue

| Review state | Count |
| --- | ---: |
| Needs editorial review | 0 |
| Needs safety review | 0 |
| Curated | 366 |

## Taxonomy distribution

| Category | Count |
| --- | ---: |
| Civil society | 75 |
| Animals and nature | 40 |
| Culture and arts | 40 |
| Celebrations | 39 |
| Relationships | 36 |
| Playful | 30 |
| Health and awareness | 28 |
| Remembrance | 25 |
| Science and curiosity | 23 |
| Food and drink | 17 |
| Professions | 7 |
| Sport and movement | 6 |

The old 272-entry `awareness` bucket and its generic copy no longer drive any
visible event. Both locales have zero legacy descriptions and zero default
sharing hooks.

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

`swift scripts/audit_content.swift --write` regenerates the current quality
snapshot. `swift scripts/audit_content.swift --strict` now passes and remains
the release-candidate content gate.
