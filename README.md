# WhaDay

Native React Native iOS app for daily themed moments and shareable story cards.

## Development

```sh
npm install
npm run pods
npm run ios
```

## Checks

```sh
npm run typecheck
npx react-native bundle --platform ios --dev false --entry-file index.ts --bundle-output /tmp/whaday-main.jsbundle --assets-dest /tmp/whaday-assets
```
