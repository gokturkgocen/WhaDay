# WhaDay 1.0 — App Store Connect Answer Sheet

Recorded: 2026-09-01
Applies to: the adless 1.0 candidate (no advertising, attribution or analytics SDK)

Every answer below is derived from what the binary actually does. If the app
changes, re-derive them; do not copy a stale sheet.

## Pricing decision

**App price: Free. WhaDay+ (`com.gokturkgocen.whaday.plus.lifetime`): ₺74.99 in
Turkey**, with Turkey as the base storefront so Apple derives the other
storefronts automatically.

Reasoning:

- WhaDay+ unlocks the Graphite and Tone share appearances. That is all. Every
  core loop — daily card, calendar, search, Discover, saved days, reminder,
  widgets, Ivory sharing — is free and stays free by product contract. Ad
  removal used to be part of the offer and is gone, because there are no ads.
- The offer is cosmetic, so the price has to sit at an impulse threshold rather
  than a value-capture one. The previous local config said ₺149.99; that was set
  when the purchase also removed advertising and is now too high for what is
  left.
- One-time, not a subscription: revenue scales with conversion volume, not with
  retention, which again argues for the lower price.
- First release, no reviews, no brand recognition. The goal of 1.0 pricing is to
  learn whether anyone pays at all.
- Raising a price later reads as confidence; cutting one reads as failure. ₺74.99
  leaves deliberate headroom for when the promised premium editorial templates
  actually ship.

Confirm the exact figure against the price points App Store Connect offers for
TRY and take the nearest available one. The `.storekit` local config has been
set to `74.99` so simulator runs and the paywall reflect the decision.

Note: the paywall still lists "future premium editorial templates" as a benefit.
That is a forward commitment attached to a one-time purchase. It is inherited
copy, not a new promise, but it is a promise — either ship those templates or
drop the line before it becomes a complaint.

## App Privacy

The app links no advertising, attribution or analytics SDK, makes no network
request for content, and stores everything in a local App Group `UserDefaults`.
`PrivacyInfo.xcprivacy` declares `NSPrivacyCollectedDataTypes` as empty,
`NSPrivacyTracking` false, and one accessed-API reason (`CA92.1`, UserDefaults).

- **Do you or your third-party partners collect data from this app?** → **No**
- Resulting label: **Data Not Collected**
- **Tracking (ATT):** none. No ATT prompt is presented.
- Third-party SDK privacy manifests: none to account for. Verified by
  inspecting the Release `.app` — no `GoogleMobileAds.framework` and no
  `UserMessagingPlatform.framework` are embedded.

If you ever reintroduce advertising, this answer becomes false and must change
before that build is submitted.

## Export compliance

- Uses encryption? → **No** (`ITSAppUsesNonExemptEncryption` is `false` in
  `Info.plist`). The app makes no HTTPS calls of its own; all content is bundled.

## Content rights

- Does your app contain, show, or access third-party content? → **No**
- All 366 dates are original editorial copy. Official observances cite primary
  sources in the in-app context sheet, which is attribution, not third-party
  content redistribution.

## Age rating

Answer every questionnaire category as **None**. Expected result: **4+**.

Two categories deserve a deliberate answer rather than a reflex:

- Some dates are remembrance or awareness observances (for example
  disappearances, disasters, disease awareness). They are written in restrained
  language under `docs/CONTENT_POLICY.md` and contain no graphic description, so
  they do not constitute mature or suggestive themes.
- No user-generated content, no chat, no web view, no gambling, no contests.

## Data and permissions the reviewer will look for

- **Notifications:** requested only after the user turns on the daily reminder in
  Settings. Never at launch.
- **Contacts, photos, location, camera, microphone:** never requested. Sharing
  hands a rendered image to the system share sheet.
- **Account:** none. Nothing to sign in to, so no demo account is needed.

## App Review notes (paste into the Notes field)

> WhaDay is a fully offline app. All 366 calendar entries and both languages are
> bundled in the binary; the app makes no network requests for content and has no
> account, no contact access, and no advertising or analytics SDK.
>
> Language follows the device locale (Turkish or English) — it is not a setting.
> To review the Turkish build, set the device language to Turkish.
>
> WhaDay+ (`com.gokturkgocen.whaday.plus.lifetime`) is a single non-consumable
> that unlocks two additional share appearances (Graphite and Tone). It is
> reachable from About WhaDay → WHADAY+, or by selecting a locked appearance in
> the Share Studio. Restore is in the same paywall sheet. No feature other than
> those two appearances is gated.
>
> Notification permission is requested only after the daily reminder toggle in
> About WhaDay is switched on, never at launch.
>
> Sharing renders an image locally and passes it to the system share sheet. If
> Instagram is installed, the Story action can open Instagram directly; if not,
> it falls back to the share sheet.

## Still to be done by hand in App Store Connect

1. Create or confirm the app record, SKU, bundle id `com.gokturkgocen.whadayapp`,
   primary language **Turkish**.
2. Create the non-consumable **WhaDay+** with product id
   `com.gokturkgocen.whaday.plus.lifetime`, price ₺74.99, localized name and
   description matching `WhaDayNative/Purchases/WhaDay.storekit`, plus a review
   screenshot of the paywall. Submit it **with** the app, not after.
3. Enter the support and privacy URLs:
   - `https://gokturkgocen.github.io/WhaDay/support/`
   - `https://gokturkgocen.github.io/WhaDay/privacy/`
4. Answer App Privacy as above (Data Not Collected).
5. Upload the four Turkish 1320 × 2868 screenshots from
   `marketing/app-store/tr-TR/`. The fifth slot is deliberately empty — see
   `marketing/app-store/README.md`.
6. Set the app name. `WhaDay` alone was reported unavailable; the decided
   listing name is `WhaDay: A Reason to Share`. Since the primary language is
   Turkish, consider a Turkish name for the Turkish localization instead.
7. Validate purchase, restore and Ask to Buy in sandbox before submitting.
