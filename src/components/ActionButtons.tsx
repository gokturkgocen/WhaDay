import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Platform } from 'react-native';
import AppBlur from './AppBlur';
import { triggerLightImpact, triggerMediumImpact } from '../utils/haptics';

interface ActionButtonsProps {
    primaryLabel: string;
    secondaryLabel: string;
    onPrimaryPress: () => void;
    onSecondaryPress: () => void;
    accentColor: string;
}

export default function ActionButtons({
    primaryLabel,
    secondaryLabel,
    onPrimaryPress,
    onSecondaryPress,
    accentColor,
}: ActionButtonsProps) {
    const handlePrimary = () => {
        triggerMediumImpact();
        onPrimaryPress();
    };

    const handleSecondary = () => {
        triggerLightImpact();
        onSecondaryPress();
    };

    return (
        <View style={styles.container}>
            <TouchableOpacity onPress={handlePrimary} activeOpacity={0.75} style={styles.primaryWrapper}>
                <View style={[styles.primaryBtn, { backgroundColor: accentColor + '30', borderColor: accentColor + '60' }]}>
                    <Text style={[styles.primaryText, { color: '#ffffff' }]}>{primaryLabel}</Text>
                </View>
            </TouchableOpacity>

            <TouchableOpacity onPress={handleSecondary} activeOpacity={0.6}>
                <View style={[styles.secondaryBtn, { backgroundColor: 'rgba(255,255,255,0.08)' }]}>
                    <Text style={styles.secondaryText}>{secondaryLabel}</Text>
                </View>
            </TouchableOpacity>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        paddingHorizontal: 28,
        paddingBottom: Platform.OS === 'ios' ? 48 : 28,
        gap: 12,
    },
    primaryWrapper: {
        borderRadius: 20,
        overflow: 'hidden',
    },
    primaryBtn: {
        paddingVertical: 18,
        paddingHorizontal: 32,
        borderRadius: 20,
        borderWidth: 0.5,
        alignItems: 'center',
    },
    primaryText: {
        fontSize: 17,
        fontWeight: '700',
        letterSpacing: 0.2,
        textAlign: 'center',
    },
    secondaryBtn: {
        paddingVertical: 14,
        paddingHorizontal: 28,
        borderRadius: 16,
        overflow: 'hidden',
        borderWidth: 0.5,
        borderColor: 'rgba(255,255,255,0.12)',
        alignItems: 'center',
    },
    secondaryText: {
        fontSize: 15,
        fontWeight: '600',
        color: 'rgba(255,255,255,0.7)',
        letterSpacing: 0.3,
    },
});
