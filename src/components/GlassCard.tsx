import React from 'react';
import { View, StyleSheet } from 'react-native';
import AppBlur from './AppBlur';

interface GlassCardProps {
    children: React.ReactNode;
    intensity?: number;
}

export default function GlassCard({ children, intensity = 65 }: GlassCardProps) {
    return (
        <View style={styles.wrapper}>
            <View style={styles.innerShadowTop} />
            <AppBlur intensity={intensity} tint="systemChromeMaterialDark" style={styles.blur}>
                <View style={styles.inner}>{children}</View>
            </AppBlur>
            <View style={styles.innerShadowBottom} />
        </View>
    );
}

const styles = StyleSheet.create({
    wrapper: {
        marginHorizontal: 24,
        borderRadius: 28,
        overflow: 'hidden',
        borderWidth: 0.5,
        borderColor: 'rgba(255,255,255,0.4)',
        backgroundColor: 'rgba(255,255,255,0.06)',
    },
    blur: {
        padding: 0,
    },
    inner: {
        padding: 32,
        alignItems: 'center',
        justifyContent: 'center',
    },
    innerShadowTop: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        height: 1,
        backgroundColor: 'rgba(255,255,255,0.15)',
        zIndex: 10,
    },
    innerShadowBottom: {
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        height: 1,
        backgroundColor: 'rgba(0,0,0,0.3)',
        zIndex: 10,
    },
});
