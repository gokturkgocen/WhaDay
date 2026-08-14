# Content curation batch 08 — culture-specific dates

Date: 2026-08-14

## Outcome

- The final 38 national, faith and culture-specific records received separate Turkish and English review.
- All 366 records are now `curated`.
- Generic descriptions: 0 in both locales.
- Default sharing hooks: 0 in both locales.
- Structural issues: 0.
- Semantic safety issues: 0.
- The strict content audit passes.

## Context repairs

- `01-13` is correctly named Old New Year's Eve, matching the night of the 13th leading into 14 January.
- The broad May 9 “WWII Europe” label now states the specific 9 May Victory Day tradition and uses remembrance treatment.
- `09-02` describes the formal end of the Second World War instead of presenting a broad victory celebration.
- Faith dates say which tradition observes them and avoid implying universal practice.
- National days identify the historical event and keep country-specific scope; disputed political or colonial context is not hidden.

## Reproducibility

- Apply this batch: `swift scripts/curate_cultural_batch.swift`
- Regenerate evidence: `swift scripts/audit_content.swift --write`
- Release gate: `swift scripts/audit_content.swift --strict`
