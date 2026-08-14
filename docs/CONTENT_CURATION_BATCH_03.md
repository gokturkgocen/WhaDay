# Content curation batch 03 — sourced institutional days

Date: 2026-08-14

## Outcome

- All 30 remaining records that already had verified institutional provenance received separate Turkish and English editorial review.
- Curated coverage increased from 92 to 122 records; the unreviewed queue fell to 244.
- Generic descriptions fell from 249 to 219 per locale.
- Default sharing hooks fell from 198 to 175 per locale.

## Metadata repair

The original generated ledger labeled many institutional records `playful` with shareability 5. This batch reclassified them by actual intent:

- Nature and environment: Water, Earth, Environment, Oceans, Desertification.
- Culture and knowledge: Logic, Radio, Mother Language, Books.
- Relationships and opportunity: Education, Youth Skills, Youth.
- Health and careful sharing: Blood Donor Day and World AIDS Day.
- Rights and civil society: press freedom, widows, Indigenous peoples, humanitarian work, girls, rural women, disability and the right to food.

The careful-sharing records now use `considerate`, shareability 2 and the `careful-sharing` audience. They cannot enter Weekly Picks or other engagement promotion.

## Editorial choices

- Blood donation copy points eligibility questions to official blood services and avoids pressuring a named recipient.
- Disability copy treats accessibility as a right and centers disabled people's voices.
- Indigenous Peoples Day explicitly avoids speaking over Indigenous voices.
- World Food Day is framed around the right to food, hunger and waste instead of a food celebration.
- World AIDS Day uses accurate, stigma-free language around information, testing and treatment.

## Reproducibility

- Apply this batch: `swift scripts/curate_sourced_batch.swift`
- Regenerate evidence: `swift scripts/audit_content.swift --write`
- The script refuses to curate any target whose metadata is no longer official or no longer has a source object.
