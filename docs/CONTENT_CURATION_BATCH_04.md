# Content curation batch 04 — context-sensitive observances

Date: 2026-08-14

## Outcome

- 38 observances involving health, identity, conflict, labour, rights or historical remembrance received separate Turkish and English editorial review.
- Curated coverage increased from 122 to 160 records; the unreviewed queue fell to 206.
- Generic descriptions fell from 219 to 181 per locale.
- Default sharing hooks fell from 175 to 144 per locale.
- Verified source coverage increased from 85 to 120 records.

## Safety policy applied

The generated ledger had classified many of these records as `playful` with shareability 5. This batch makes promotion conditional on context:

- Health and lived-experience observances use `considerate`, shareability 2 and `careful-sharing`.
- War-loss observances use `remembrance`, shareability 1 and are excluded from engagement promotion.
- Community celebrations such as Pride remain shareable, but their copy centers the people represented rather than treating identity as novelty.
- Country-specific military observances do not appear as universal celebrations.
- Sharing hooks for health, disability and identity records ask the sender to center reliable information or first-person voices.

## Source policy

- United Nations observances were checked against the current UN international days ledger.
- Chagas, tobacco, drowning and Breastfeeding Week were checked against the WHO campaign calendar.
- Labour dates were checked against the ILO.
- Community-origin observances use the relevant movement, advocacy organization or public historical institution rather than an unsourced holiday aggregator.

## Reproducibility

- Apply this batch: `swift scripts/curate_context_batch.swift`
- Regenerate evidence: `swift scripts/audit_content.swift --write`
- The script requires a reviewed source for every record marked `official`.
