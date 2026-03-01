import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, Platform, StatusBar } from 'react-native';
import { useTheme, BackgroundTheme } from '../hooks/ThemeContext';
import BackgroundRenderer from '../components/BackgroundRenderer';
import { getThemeForCategory } from '../utils/themes';
import GlassCard from '../components/GlassCard';

interface SettingsScreenProps {
    onBack: () => void;
    // We pass the same theme category the home screen uses so the background colors match.
    eventCategory?: string;
}

const THEMES: { id: BackgroundTheme; name: string; description: string }[] = [
    { id: 'classic', name: 'Classic Blobs', description: 'Şu anki: Yavaşça nefes alan 3 organik şekil.' },
    { id: 'aurora', name: 'Apple Aurora', description: 'Akışkan ve pürüzsüz renk geçişleri.' },
    { id: 'grain', name: 'Cinematic Grain', description: 'Film greni ve derin, fiziksel bir doku.' },
    { id: 'topo', name: 'Topography', description: 'Çok yavaş akan, minimalist yatay çizgiler.' },
    { id: 'atmosphere', name: 'Time Atmosphere', description: 'Gündüz ışık hüzmeleri, gece yıldız tozu.' },
];

export default function SettingsScreen({ onBack, eventCategory }: SettingsScreenProps) {
    const { theme, setTheme } = useTheme();
    // Default to a neutral or the current day's theme
    const themeColors = getThemeForCategory(eventCategory);

    return (
        <View style={styles.container}>
            <StatusBar barStyle="light-content" />

            {/* Arka Plan Render */}
            <BackgroundRenderer themeColors={themeColors} />

            {/* Header */}
            <View style={styles.header}>
                <TouchableOpacity onPress={onBack} style={styles.backBtn} activeOpacity={0.6}>
                    <Text style={styles.backIcon}>←</Text>
                </TouchableOpacity>
                <Text style={styles.headerTitle}>Ayarlar</Text>
                <View style={{ width: 44 }} />
            </View>

            {/* Settings List */}
            <ScrollView contentContainerStyle={styles.scrollArea}>
                <GlassCard>
                    <Text style={styles.sectionTitle}>Arka Plan Teması</Text>

                    {THEMES.map((t, index) => {
                        const isSelected = theme === t.id;
                        return (
                            <TouchableOpacity
                                key={t.id}
                                style={[
                                    styles.themeRow,
                                    index !== THEMES.length - 1 && styles.borderBottom
                                ]}
                                onPress={() => setTheme(t.id)}
                                activeOpacity={0.7}
                            >
                                <View style={styles.themeInfo}>
                                    <Text style={[styles.themeName, isSelected && styles.themeNameActive]}>
                                        {t.name}
                                    </Text>
                                    <Text style={styles.themeDesc}>{t.description}</Text>
                                </View>

                                {/* Radio/Check Indicator */}
                                <View style={[styles.radio, isSelected && { borderColor: themeColors.accent }]}>
                                    {isSelected ? <View style={[styles.radioInner, { backgroundColor: themeColors.accent }]} /> : null}
                                </View>
                            </TouchableOpacity>
                        );
                    })}
                </GlassCard>
            </ScrollView>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    header: {
        paddingTop: Platform.OS === 'ios' ? 70 : 50,
        paddingHorizontal: 24,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingBottom: 20,
    },
    backBtn: {
        width: 44,
        height: 44,
        borderRadius: 14,
        backgroundColor: 'rgba(255,255,255,0.1)',
        borderWidth: 0.5,
        borderColor: 'rgba(255,255,255,0.2)',
        alignItems: 'center',
        justifyContent: 'center',
    },
    backIcon: {
        color: 'rgba(255,255,255,0.8)',
        fontSize: 24,
        fontWeight: '300',
        marginTop: -4,
    },
    headerTitle: {
        fontSize: 20,
        fontWeight: '700',
        color: '#fff',
    },
    scrollArea: {
        paddingTop: 16,
        paddingBottom: 40,
    },
    sectionTitle: {
        width: '100%',
        textAlign: 'left',
        fontSize: 16,
        fontWeight: '600',
        color: 'rgba(255,255,255,0.8)',
        marginBottom: 16,
        textTransform: 'uppercase',
        letterSpacing: 1,
    },
    themeRow: {
        width: '100%',
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingVertical: 16,
    },
    borderBottom: {
        borderBottomWidth: 0.5,
        borderBottomColor: 'rgba(255,255,255,0.15)',
    },
    themeInfo: {
        flex: 1,
        paddingRight: 16,
    },
    themeName: {
        fontSize: 18,
        fontWeight: '600',
        color: 'rgba(255,255,255,0.7)',
        marginBottom: 4,
    },
    themeNameActive: {
        color: '#fff',
        fontWeight: '700',
    },
    themeDesc: {
        fontSize: 14,
        color: 'rgba(255,255,255,0.5)',
        lineHeight: 20,
    },
    radio: {
        width: 24,
        height: 24,
        borderRadius: 12,
        borderWidth: 2,
        borderColor: 'rgba(255,255,255,0.3)',
        alignItems: 'center',
        justifyContent: 'center',
    },
    radioInner: {
        width: 12,
        height: 12,
        borderRadius: 6,
    },
});
