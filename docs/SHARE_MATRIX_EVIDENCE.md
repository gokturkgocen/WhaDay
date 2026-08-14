# Share Matrix Evidence

Date: 2026-08-14

The release-candidate share-card gate rendered every supported combination:

- 366 day entries
- Turkish and English
- Editorial, Playful and Minimal styles
- Story (1080 x 1920) and Message (1080 x 1350) formats
- 4,392 renders in total

`EditorialContentTests.testCompleteShareMatrixRendersWhenRequested` completed with zero failures on an iPhone 17 / iOS 26.5 simulator at app/content revision `5d78bd0`. Every render returned an image at the exact expected pixel dimensions. The render loop completed in 15.278 seconds. The same test operation executed all 53 unit, integration, reliability, performance and render tests with zero failures and zero skips.

This gate proves that the full matrix can be decoded and rendered without a nil image, crash, or output-dimension regression. It does not replace visual review of representative cards or delivery checks in Instagram, WhatsApp and Messages on a physical device.

Representative current-revision Home, Share Studio and Discovery captures were inspected at standard and accessibility text sizes. The standard layout had no visible clipping, unsafe-edge placement or illegible hierarchy; the compact accessibility layout kept core actions reachable through scrolling and used intentional single-line ellipsis only for secondary discovery summaries. Physical destination-app delivery remains an open device gate.

The expensive gate is opt-in for normal development runs. Before running the selected test on a booted simulator, enable its process environment with `xcrun simctl spawn <UDID> launchctl setenv WHADAY_FULL_SHARE_MATRIX 1`. Remove it afterwards with the matching `launchctl unsetenv` command.
