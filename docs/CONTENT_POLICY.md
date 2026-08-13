# WhaDay Content Policy

WhaDay turns each calendar date into a reason to connect. It mixes recognized
international observances, cultural dates and light-hearted calendar prompts,
but it must never imply that every entry has the same official status.

## Calendar rules

- The bundled dataset represents dates that recur on the same month and day.
- Do not add observances defined as “first Monday”, “third Sunday”, lunar dates
  or similar moving rules as permanent month/day entries.
- When a moving observance is valuable, add year-aware date support first.
- Prefer primary sources when validating names and dates:
  - United Nations: https://www.un.org/en/observances/list-days-weeks
  - UNESCO: https://www.unesco.org/en/days/list
  - World Health Organization: https://www.who.int/campaigns
  - International Maritime Organization: https://www.imo.org/

## Voice rules

- The title says what the day is; the supporting copy must add meaning instead
  of repeating the title.
- Facts should remain under 190 characters in each supported language.
- Prompts should identify a natural recipient whenever the subject is playful
  or relational.
- Turkish copy must read as original Turkish, not as a literal translation.
- English copy should carry the same intent rather than mirror word order.

## Sensitive and remembrance days

- Use `BUGÜNÜN NOTU` / `TODAY'S NOTE`, never “today's excuse”.
- Use a careful sharing prompt and avoid jokes, guilt, commands or engagement
  bait.
- Center affected people, dignity, rights, listening and reliable information.
- Do not use unsupported statistics or medical advice.
- Suicide-prevention copy should encourage non-judgmental listening and access
  to professional support without implying that a message alone is a solution.

## Quality gate

`EditorialContentTests` must iterate through the entire dataset and reject
empty copy, legacy boilerplate, overlong facts and moving observances stored as
fixed dates.
