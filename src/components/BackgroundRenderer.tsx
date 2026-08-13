import React, { useEffect } from 'react';
import { View, StyleSheet } from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import { useTheme } from '../hooks/ThemeContext';
import AnimatedBackground from './AnimatedBackground';
import ThemeAurora from './themes/ThemeAurora';
import ThemeGrain from './themes/ThemeGrain';
import ThemeTopo from './themes/ThemeTopo';
import ThemeAtmosphere from './themes/ThemeAtmosphere';
import { startGlobalAnimations } from './themes/GlobalAnim';

interface BackgroundRendererProps {
    themeColors: {
        gradient: readonly [string, string, ...string[]];
        blob1: string;
        blob2: string;
        blob3: string;
    };
}

export default function BackgroundRenderer({ themeColors }: BackgroundRendererProps) {
    const { theme } = useTheme();

    // Start all shared animations as soon as the background layer mounts
    useEffect(() => {
        startGlobalAnimations();
    }, []);

    return (
        <View style={StyleSheet.absoluteFill} pointerEvents="none">
            <LinearGradient colors={[...themeColors.gradient]} style={StyleSheet.absoluteFill} />

            {theme === 'classic' ? (
                <AnimatedBackground
                    blob1Color={themeColors.blob1}
                    blob2Color={themeColors.blob2}
                    blob3Color={themeColors.blob3}
                />
            ) : null}

            {theme === 'aurora' ? (
                <ThemeAurora
                    blob1Color={themeColors.blob1}
                    blob2Color={themeColors.blob2}
                    blob3Color={themeColors.blob3}
                />
            ) : null}

            {theme === 'grain' ? <ThemeGrain /> : null}

            {theme === 'topo' ? <ThemeTopo /> : null}

            {theme === 'atmosphere' ? <ThemeAtmosphere /> : null}
        </View>
    );
}
