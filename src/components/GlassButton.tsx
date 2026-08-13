import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import AppBlur from './AppBlur';

interface GlassButtonProps {
    label: string;
    onPress: () => void;
    variant?: 'primary' | 'secondary';
}

export default function GlassButton({ label, onPress, variant = 'primary' }: GlassButtonProps) {
    return (
        <TouchableOpacity onPress={onPress} activeOpacity={0.7} style={styles.wrapper}>
            <AppBlur
                intensity={variant === 'primary' ? 60 : 30}
                tint="light"
                style={styles.blur}
            >
                <View style={[
                    styles.inner,
                    variant === 'primary' ? styles.primaryInner : styles.secondaryInner,
                ]}>
                    <Text style={[
                        styles.label,
                        variant === 'primary' ? styles.primaryLabel : styles.secondaryLabel,
                    ]}>
                        {label}
                    </Text>
                </View>
            </AppBlur>
        </TouchableOpacity>
    );
}

const styles = StyleSheet.create({
    wrapper: {
        borderRadius: 50,
        overflow: 'hidden',
        borderWidth: 1,
        borderColor: 'rgba(255,255,255,0.25)',
        shadowColor: '#fff',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.15,
        shadowRadius: 12,
        elevation: 6,
    },
    blur: {
        borderRadius: 50,
    },
    inner: {
        paddingVertical: 18,
        paddingHorizontal: 32,
        alignItems: 'center',
        justifyContent: 'center',
        borderRadius: 50,
    },
    primaryInner: {
        backgroundColor: 'rgba(255,255,255,0.18)',
    },
    secondaryInner: {
        backgroundColor: 'rgba(255,255,255,0.08)',
    },
    label: {
        fontSize: 17,
        fontWeight: '700',
        letterSpacing: 0.3,
    },
    primaryLabel: {
        color: '#ffffff',
    },
    secondaryLabel: {
        color: 'rgba(255,255,255,0.8)',
    },
});
