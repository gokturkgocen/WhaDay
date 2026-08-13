import ReactNativeHapticFeedback from 'react-native-haptic-feedback';

const options = {
    enableVibrateFallback: true,
    ignoreAndroidSystemSettings: false,
};

export function triggerLightImpact() {
    ReactNativeHapticFeedback.trigger('impactLight', options);
}

export function triggerMediumImpact() {
    ReactNativeHapticFeedback.trigger('impactMedium', options);
}
