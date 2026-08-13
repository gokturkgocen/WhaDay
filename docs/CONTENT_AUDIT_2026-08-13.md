# WhaDay Content Audit

Audit date: 2026-08-13

## Dataset integrity

- Turkish entries: 366
- English entries: 366
- Missing or extra IDs between languages: 0
- Duplicate IDs detected: 0
- Leap day is present.

## Editorial debt found

The dataset is structurally complete but is not yet editorially complete:

- 337 of 366 Turkish descriptions use the same generic “globally celebrated” template.
- 337 of 366 English descriptions use the equivalent generic template.
- 272 entries (74%) use the broad `awareness` category.
- 234 entries (64%) combine the default bell, awareness category and generic awareness hook.
- 266 Turkish hooks repeat “Farkındalık yayarak bilgilendir”; the English set repeats “Raise awareness” 266 times.

The current native app protects the main experience from the worst repetition by generating `EditorialContent` from semantic lenses and by rendering a neutral ✦ instead of the default bell. The raw description and sharing-hook fields are not shown on the main card. This does not remove the underlying content debt: category distribution still controls visual themes, shortlist scoring and some widget behavior.

## Product risk

- Too many days look and feel like the same generic awareness entry.
- Country, faith, serious observance and playful internet-calendar prompts can appear adjacent without enough hierarchy.
- “National” days are often culture-specific but may read as universal when the country is absent from the title.
- A complete 366-row file can create a false sense that every date has been independently researched.

## Editorial remediation order

1. **Authority:** classify each entry as official, cultural or WhaDay editorial; attach a primary source only when verified.
2. **Safety:** finish the remembrance, health, conflict and rights review before using those days in notifications or social promotion.
3. **Social fit:** give playful and relational days a natural recipient, specific symbol and useful category.
4. **Localization:** rewrite Turkish as native Turkish first, then adapt intent into English instead of translating sentence structure.
5. **Schema cleanup:** replace or remove unused generic description/hook fields after all consumers are confirmed.

## Release position

The app can be tested with the existing defensive editorial layer, but the 366-day corpus should not be described as fully researched or fully curated yet. Store copy should promise a daily discovery and transparent provenance, not claim that every entry is an official international day.
