# Widget Evidence

Date: 2026-08-14

The widget extension now ships the same Turkish, English and metadata resources as the app, so its first timeline does not depend on the app having written shared state. SHA-256 checks confirmed that all three resources in the built extension match their source files exactly.

The shared widget catalog is covered for:

- 366 Turkish and 366 English entries, including February 29
- metadata-driven symbols, themes and sensitive-day tone
- safe degradation when metadata is malformed
- Turkish, English and unsupported device-language selection
- the next local midnight across a daylight-saving transition

The extension build succeeded and the complete unit suite passed with 40 tests executed, one opt-in share-matrix test skipped, and zero failures. Home Screen small/medium families and Lock Screen accessory rectangular are compiled for iOS 17 and later. Widget taps retain exact `whaday://day/<MM-DD>` routing.

Physical Home Screen and Lock Screen placement, VoiceOver traversal and midnight delivery remain part of the final device scenario gate; the automated checks do not claim those interactions are physically verified.
