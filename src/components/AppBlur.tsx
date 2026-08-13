import React from 'react';
import { BlurView, type BlurViewProps } from '@react-native-community/blur';

type BlurTint =
    | 'light'
    | 'dark'
    | 'default'
    | 'systemChromeMaterialDark'
    | 'systemChromeMaterialLight';

interface AppBlurProps extends Omit<BlurViewProps, 'blurType' | 'blurAmount'> {
    intensity?: number;
    tint?: BlurTint;
    reducedTransparencyFallbackColor?: string;
}

function mapTintToBlurType(tint: BlurTint): BlurViewProps['blurType'] {
    switch (tint) {
        case 'dark':
            return 'dark';
        case 'systemChromeMaterialDark':
            return 'chromeMaterialDark';
        case 'systemChromeMaterialLight':
            return 'chromeMaterialLight';
        case 'default':
            return 'regular';
        case 'light':
        default:
            return 'light';
    }
}

export default function AppBlur({
    intensity = 30,
    tint = 'default',
    reducedTransparencyFallbackColor = 'rgba(18,18,18,0.65)',
    ...props
}: AppBlurProps) {
    return (
        <BlurView
            {...props}
            blurType={mapTintToBlurType(tint)}
            blurAmount={Math.min(32, Math.max(1, Math.round(intensity / 3)))}
            reducedTransparencyFallbackColor={reducedTransparencyFallbackColor}
        />
    );
}
