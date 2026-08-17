# WhaDay Post-1.0 Backlog

Status: Planned, not started
Recorded: 2026-08-17

Capabilities that are deliberately outside
[`PRODUCT_CONTRACT.md`](PRODUCT_CONTRACT.md)'s 1.0 scope but are intended
product direction. Nothing here may be implemented before the 1.0 release
candidate closes.

## Sealed personal day

A user creates or personalizes a date, writes a message on it, and attaches one
person to it. The message stays invisible to the recipient until that calendar
date arrives; on the date both sides see the same card at the same time.

### Intended rules

- A date can carry a user-authored title and message alongside the editorial
  event, or stand alone as a user-created date.
- Exactly one recipient is attached per sealed day.
- The recipient sees nothing — not the existence of the day, not a teaser —
  before the unlock date.
- On the unlock date the sealed content becomes visible to both sides
  simultaneously.
- A sealed message cannot be deleted or withdrawn before its unlock date.
  WhaDay+ is the exception: an entitled user may withdraw or edit a sealed
  message while it is still sealed.

The withdraw-before-unlock ability is the monetization hook, so it is a product
rule, not a technical convenience.

### What this breaks in the current architecture

This feature contradicts five committed 1.0 non-goals at once: accounts and
cloud sync, an in-app friend graph, direct messages, user-created calendar
dates, and offline-first operation. It also changes the app's App Store data
collection disclosures and privacy policy, because user-authored content and a
recipient identifier would leave the device.

`PRODUCT_CONTRACT.md` states the core product works with no account, no contact
access and no network. Sealed delivery to another person cannot be built without
relaxing part of that promise. Which part is relaxed is an open product
decision, recorded below rather than assumed.

### Two candidate architectures

**A — Sealed payload over existing share channels (keeps the offline posture).**
The sender produces an encoded payload and hands it over through the channels
the app already uses (Messages, WhatsApp, share sheet, deep link). The
recipient's app stores it locally and refuses to render it before the unlock
date. No account, no server, no new network dependency.

Honest limitations: the seal is client-enforced, so a device clock change or an
inspected payload can defeat it — it is a social promise, not secrecy. And once
the payload has been handed over, the sender cannot withdraw it, which means the
WhaDay+ withdraw ability degrades to "before you send it" and the premium hook
mostly disappears.

**B — Server-held delivery (breaks the offline posture).** A minimal backend
holds the sealed message until its unlock date, then releases it and pushes a
notification to both sides. This is the only variant where the stated rules hold
literally: the recipient genuinely cannot access the content early, and
withdrawal before unlock is enforceable.

Cost: account or durable device identity, recipient addressing, push
infrastructure, server-side retention of user-authored personal messages,
updated privacy policy and data-collection disclosures, and a network dependency
in a product currently sold as offline-first.

Recommendation: B, because A cannot deliver the two rules that define the
feature (a real seal and a premium withdrawal). If the offline promise is
considered non-negotiable, the feature should be reshaped rather than shipped as
A and described as if it were B.

### Open questions

- Does the WhaDay+ exception cover editing as well as withdrawal, or withdrawal
  only?
- How is a recipient addressed without contact access — an in-app share link the
  sender passes over an existing channel, or an account handle?
- What happens to a sealed day whose recipient never installs or opens the app?
- Is a user-created date reusable every year, or a single-occurrence event?
- Does a sealed day appear in the sender's calendar before unlock, and is it
  visible in the widget?
- Retention: how long is delivered sealed content kept, and can either side
  delete it after unlock?

### Dependencies

Blocked on the 1.0 release candidate closing, and on a product decision between
architectures A and B. The decision comes before any implementation work,
because it determines whether this is a client-only feature or a backend
project.
