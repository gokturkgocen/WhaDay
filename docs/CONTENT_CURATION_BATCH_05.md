# Content curation batch 05 — high-shareability editorial days

Date: 2026-08-14

## Outcome

- 50 light, person-to-person WhaDay prompts received hand-written Turkish and English copy.
- Every sharing hook names a recognizable recipient or relationship instead of asking users to “raise awareness.”
- Curated coverage increased from 160 to 210 records; the unreviewed queue fell to 156.
- Generic descriptions fell from 181 to 155 per locale.
- Default sharing hooks fell from 144 to 118 per locale.

## Voice rules

- The description earns attention with one concrete image, useful fact or playful observation.
- The hook answers “who would I send this to?” in one line.
- WhaDay-created prompts are explicitly scoped as `whaday-editorial`; they are not presented as official observances.
- Consent and respect remain explicit where a playful title could otherwise invite unwanted contact.
- Wellness copy avoids pretending that positivity or self-care solves structural or medical problems.

## Product role

These records are the app's primary organic-sharing layer. They keep shareability 5 and can enter Weekly Picks because their copy is designed for a direct friend, sibling, partner or community connection.

## Reproducibility

- Apply this batch: `swift scripts/curate_shareable_batch.swift`
- Regenerate evidence: `swift scripts/audit_content.swift --write`
- The script refuses to convert non-editorial records into WhaDay-created prompts.
