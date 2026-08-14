# Content curation batch 01 — safety, health and remembrance

Date: 2026-08-14

## Outcome

- 50 records were reviewed in Turkish, English and locale-neutral metadata.
- 47 externally established days now carry checked primary-source provenance.
- 31 considerate records and 17 remembrance records are blocked from engagement promotion.
- Every non-standard record renders as `BUGÜNÜN NOTU` / `TODAY'S NOTE`, never as an excuse.
- The content audit reports zero structural issues and zero semantic safety issues.

## Corrections made during review

### 15 November metadata mismatch

The localized catalog correctly named the UN International Day for the Prevention of and Fight against All Forms of Transnational Organized Crime, but its metadata classified it as a playful, friend-targeted, shareability-5 day. It is now official civil-society content, considerate, shareability 2, and sourced to the United Nations.

### 17 November stale observance

WHO moved World Prematurity Day from its traditional 17 November date to 15 November beginning in 2025. Because WhaDay stores one fixed card per calendar date and 15 November already holds a UN observance, the stale 17 November record was removed. It is now the clearly attributed WhaDay editorial prompt `İlk Mesajı Atma Günü` / `Text First Day`.

Primary date evidence: <https://www.who.int/campaigns/world-prematurity-day>

## Editorial rules applied

- Remembrance copy honors victims and survivors without calls for celebration, tagging or performative engagement.
- Health copy avoids diagnosis or personalized medical advice and directs the tone toward reliable information, access to care and lived experience.
- Suicide-prevention copy does not imply that one message is a complete intervention; it emphasizes non-judgmental listening and connection to professional support.
- Violence and abuse copy uses survivor-aware language and avoids sensational details.
- Institutionally established days are `official`; community-established campaigns are `cultural`; WhaDay-created prompts are `editorial`.
- A source check does not by itself mark copy curated. All 50 records in this batch received separate bilingual copy and metadata review.

## Reproducible evidence

- Apply the reviewed batch: `swift scripts/curate_safety_batch.swift`
- Regenerate the audit: `swift scripts/audit_content.swift --write`
- Release-candidate audit: `swift scripts/audit_content.swift --strict`
- Source mappings and bilingual copy live in `scripts/curate_safety_batch.swift` so changes are reviewable and repeatable.

## Verification result

- Unit, integration, rendering and performance tests: 51 executed, 50 passed, 1 opt-in full share-matrix test skipped, 0 failed.
- The 4,392-render share matrix remains the explicit release-candidate gate and was not silently counted as passed in this batch.
- Temporary simulator and derived data were removed after the run; no simulator remains booted.

## Remaining content work

This is not the final content sign-off. After this batch, 316 records remain unreviewed and legacy generic copy remains in 288 Turkish and 288 English descriptions. The next batches prioritize shareability-5 relational, playful, food, animal and culture days while continuing authority and date checks.
