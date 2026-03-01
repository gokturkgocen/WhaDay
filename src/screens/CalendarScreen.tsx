import React, { useRef } from 'react';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    TouchableOpacity,
    Platform,
    StatusBar,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { BlurView } from 'expo-blur';
import { getDeviceLanguage, getDateLocale } from '../hooks/useDayEvent';
import { getStrings } from '../utils/strings';
import { getThemeForCategory } from '../utils/themes';

import enData from '../data/en.json';
import trData from '../data/tr.json';
import type { DayEvent } from '../hooks/useDayEvent';

interface CalendarScreenProps {
    onBack: () => void;
    onSelectDay: (event: DayEvent) => void;
    selectedDay?: DayEvent | null;
}

export default function CalendarScreen({ onBack, onSelectDay, selectedDay }: CalendarScreenProps) {
    const lang = getDeviceLanguage();
    const dateLocale = getDateLocale();
    const days: DayEvent[] = lang === 'tr' ? trData : enData;
    const ui = getStrings(lang);

    const now = new Date();
    const todayMonth = now.getMonth() + 1;
    const todayDay = now.getDate();

    const monthNames: Record<string, string[]> = {
        tr: ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'],
        en: ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    };

    const grouped = days.reduce((acc, day) => {
        if (!acc[day.month]) acc[day.month] = [];
        acc[day.month].push(day);
        return acc;
    }, {} as Record<number, DayEvent[]>);

    const scrollViewRef = useRef<ScrollView>(null);
    const monthYRefs = useRef<Record<number, number>>({});
    const todayDayYRef = useRef<number | null>(null);
    const hasScrolled = useRef(false);

    const tryScrollToToday = () => {
        if (hasScrolled.current) return;
        const mY = monthYRefs.current[todayMonth];
        const dY = todayDayYRef.current;
        if (mY !== undefined && dY !== null && scrollViewRef.current) {
            hasScrolled.current = true;
            // Biraz boşluk bırakarak güne odaklansın
            scrollViewRef.current.scrollTo({ y: Math.max(0, mY + dY - 20), animated: false });
        }
    };

    return (
        <View style={styles.container}>
            <StatusBar barStyle="light-content" />
            <LinearGradient
                colors={['#0f0c29', '#1a1640', '#0f0c29']}
                style={StyleSheet.absoluteFill}
            />

            {/* Header */}
            <View style={styles.header}>
                <TouchableOpacity onPress={onBack} style={styles.backButton}>
                    <Text style={styles.backText}>← </Text>
                </TouchableOpacity>
                <Text style={styles.headerTitle}>
                    {lang === 'tr' ? 'Takvim' : 'Calendar'}
                </Text>
                <View style={{ width: 40 }} />
            </View>

            <ScrollView
                ref={scrollViewRef}
                style={styles.scroll}
                contentContainerStyle={styles.scrollContent}
                showsVerticalScrollIndicator={false}
            >
                {Object.entries(grouped).map(([monthStr, events]) => {
                    const month = Number(monthStr);
                    const monthName = (monthNames[lang] ?? monthNames.en)[month];

                    return (
                        <View
                            key={month}
                            style={styles.monthSection}
                            onLayout={(e) => {
                                monthYRefs.current[month] = e.nativeEvent.layout.y;
                                if (month === todayMonth) tryScrollToToday();
                            }}
                        >
                            <Text style={styles.monthTitle}>{monthName}</Text>
                            {events.map((event) => {
                                const isToday = event.month === todayMonth && event.day === todayDay;
                                const isSelected = selectedDay
                                    ? event.month === selectedDay.month && event.day === selectedDay.day
                                    : isToday;
                                const theme = getThemeForCategory(event.category);

                                return (
                                    <View
                                        key={event.id}
                                        onLayout={(e) => {
                                            if (isToday) {
                                                todayDayYRef.current = e.nativeEvent.layout.y;
                                                tryScrollToToday();
                                            }
                                        }}
                                    >
                                        <TouchableOpacity
                                            onPress={() => onSelectDay(event)}
                                            activeOpacity={0.7}
                                        >
                                            <View style={[
                                                styles.dayCard,
                                                isSelected && { borderColor: theme.accent, borderWidth: 1.5 },
                                            ]}>
                                                <BlurView intensity={20} tint="dark" style={styles.dayBlur}>
                                                    <View style={styles.dayRow}>
                                                        <View style={[styles.dayBadge, { backgroundColor: theme.accent + '30' }]}>
                                                            <Text style={styles.dayNumber}>{event.day}</Text>
                                                        </View>
                                                        <View style={styles.dayInfo}>
                                                            <Text style={styles.dayEmoji}>{event.emoji}</Text>
                                                            <Text style={styles.dayTitle}>{event.title}</Text>
                                                        </View>
                                                        {isToday ? (
                                                            <View style={[styles.todayBadge, { backgroundColor: theme.accent }]}>
                                                                <Text style={styles.todayText}>
                                                                    {lang === 'tr' ? 'Bugün' : 'Today'}
                                                                </Text>
                                                            </View>
                                                        ) : null}
                                                    </View>
                                                </BlurView>
                                            </View>
                                        </TouchableOpacity>
                                    </View>
                                );
                            })}
                        </View>
                    );
                })}
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
        paddingHorizontal: 20,
        paddingBottom: 16,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
    },
    backButton: {
        width: 40,
        height: 40,
        borderRadius: 20,
        backgroundColor: 'rgba(255,255,255,0.1)',
        alignItems: 'center',
        justifyContent: 'center',
    },
    backText: {
        fontSize: 20,
        color: '#fff',
    },
    headerTitle: {
        fontSize: 20,
        fontWeight: '700',
        color: '#fff',
    },
    scroll: {
        flex: 1,
    },
    scrollContent: {
        paddingHorizontal: 20,
        paddingBottom: 40,
    },
    monthSection: {
        marginBottom: 28,
    },
    monthTitle: {
        fontSize: 24,
        fontWeight: '800',
        color: 'rgba(255,255,255,0.4)',
        marginBottom: 12,
        letterSpacing: 1,
        textTransform: 'uppercase',
    },
    dayCard: {
        borderRadius: 18,
        overflow: 'hidden',
        marginBottom: 10,
        borderWidth: 1,
        borderColor: 'rgba(255,255,255,0.08)',
    },
    dayBlur: {
        borderRadius: 18,
    },
    dayRow: {
        flexDirection: 'row',
        alignItems: 'center',
        padding: 14,
        gap: 12,
    },
    dayBadge: {
        width: 44,
        height: 44,
        borderRadius: 14,
        alignItems: 'center',
        justifyContent: 'center',
    },
    dayNumber: {
        fontSize: 18,
        fontWeight: '700',
        color: '#fff',
    },
    dayInfo: {
        flex: 1,
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
    },
    dayEmoji: {
        fontSize: 22,
    },
    dayTitle: {
        fontSize: 16,
        fontWeight: '600',
        color: '#fff',
        flex: 1,
    },
    todayBadge: {
        paddingHorizontal: 10,
        paddingVertical: 4,
        borderRadius: 10,
    },
    todayText: {
        fontSize: 11,
        fontWeight: '700',
        color: '#fff',
    },
});
