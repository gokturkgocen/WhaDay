import React, { useEffect, useRef, useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    StatusBar,
    TouchableOpacity,
    Platform,
    Animated,
    FlatList,
    Dimensions,
    Share,
} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import ViewShot from 'react-native-view-shot';
import { Settings } from 'lucide-react-native';
import { useTheme } from '../hooks/ThemeContext';
import { useTodayEvent, getDateLocale, getDeviceLanguage } from '../hooks/useDayEvent';
import { getStrings } from '../utils/strings';
import { getThemeForCategory } from '../utils/themes';
import { triggerLightImpact, triggerMediumImpact } from '../utils/haptics';
import { saveDayToWidget } from '../modules/SharedWidgetData';
import GlassCard from '../components/GlassCard';
import BackgroundRenderer from '../components/BackgroundRenderer';
import ActionButtons from '../components/ActionButtons';
import type { DayEvent } from '../hooks/useDayEvent';
import enData from '../data/en.json';
import trData from '../data/tr.json';

interface HomeScreenProps {
    onOpenCalendar: () => void;
    onOpenSettings: () => void;
    onSelectDay: (event: DayEvent) => void;
    selectedDay?: DayEvent | null;
}

const { width } = Dimensions.get('window');

export default function HomeScreen({ onOpenCalendar, onOpenSettings, onSelectDay, selectedDay }: HomeScreenProps) {
    const { theme: backgroundTheme } = useTheme();
    const todayEvent = useTodayEvent();
    const displayEvent = selectedDay ?? todayEvent;

    const lang = getDeviceLanguage();
    const dateLocale = getDateLocale();
    const ui = getStrings(lang);
    const theme = getThemeForCategory(displayEvent?.category);

    const shareCardRef = useRef<ViewShot>(null);
    const flatListRef = useRef<FlatList<DayEvent>>(null);
    const days: DayEvent[] = lang === 'tr' ? trData : enData;

    const initialIndex = Math.max(0, days.findIndex((day) => day.id === displayEvent?.id));
    const scrollX = useRef(new Animated.Value(initialIndex * width)).current;
    const [activeIndex, setActiveIndex] = useState(initialIndex);
    const activeIndexRef = useRef(activeIndex);
    const initialIndexRef = useRef(initialIndex);

    const headerOpacity = useRef(new Animated.Value(0)).current;
    const cardTranslateY = useRef(new Animated.Value(50)).current;
    const cardOpacity = useRef(new Animated.Value(0)).current;
    const emojiScale = useRef(new Animated.Value(0.5)).current;
    const buttonOpacity = useRef(new Animated.Value(0)).current;
    const onSelectDayRef = useRef(onSelectDay);

    useEffect(() => {
        onSelectDayRef.current = onSelectDay;
    }, [onSelectDay]);

    useEffect(() => {
        if (displayEvent) {
            saveDayToWidget(displayEvent, backgroundTheme, theme);
        }
    }, [backgroundTheme, displayEvent, theme]);

    useEffect(() => {
        Animated.stagger(150, [
            Animated.timing(headerOpacity, {
                toValue: 1,
                duration: 500,
                useNativeDriver: true,
            }),
            Animated.parallel([
                Animated.spring(cardTranslateY, {
                    toValue: 0,
                    damping: 15,
                    stiffness: 80,
                    useNativeDriver: true,
                }),
                Animated.timing(cardOpacity, {
                    toValue: 1,
                    duration: 400,
                    useNativeDriver: true,
                }),
            ]),
            Animated.spring(emojiScale, {
                toValue: 1,
                damping: 6,
                stiffness: 120,
                useNativeDriver: true,
            }),
            Animated.timing(buttonOpacity, {
                toValue: 1,
                duration: 350,
                useNativeDriver: true,
            }),
        ]).start();
    }, [buttonOpacity, cardOpacity, cardTranslateY, emojiScale, headerOpacity]);

    useEffect(() => {
        const index = days.findIndex((day) => day.id === selectedDay?.id);
        if (index !== -1 && flatListRef.current && index !== activeIndexRef.current) {
            flatListRef.current.scrollToIndex({ index, animated: false });
            activeIndexRef.current = index;
            setActiveIndex(index);
            scrollX.setValue(index * width);
        }
    }, [days, scrollX, selectedDay?.id]);

    const onScroll = Animated.event(
        [{ nativeEvent: { contentOffset: { x: scrollX } } }],
        { useNativeDriver: true },
    );

    const onMomentumScrollEnd = (event: any) => {
        const index = Math.round(event.nativeEvent.contentOffset.x / width);
        if (index !== activeIndexRef.current) {
            activeIndexRef.current = index;
            setActiveIndex(index);
            const day = days[index];
            if (day) onSelectDayRef.current(day);
        }
    };

    const handleShare = async () => {
        if (!displayEvent || !shareCardRef.current?.capture) return;

        try {
            triggerMediumImpact();
            const uri = await shareCardRef.current.capture();
            await Share.share({
                title: displayEvent.title,
                message: displayEvent.sharingHook || displayEvent.title,
                url: uri,
            });
        } catch (error) {
            console.log('Share error:', error);
        }
    };

    const now = new Date();
    const prevIndex = Math.max(0, activeIndex - 1);
    const nextIndex = Math.min(days.length - 1, activeIndex + 1);
    const activeIndices = Array.from(new Set([prevIndex, activeIndex, nextIndex]));

    return (
        <View style={styles.container}>
            <StatusBar barStyle="light-content" />

            <View style={[StyleSheet.absoluteFill, { zIndex: -1 }]}>
                {activeIndices.map((index) => {
                    const item = days[index];
                    const itemTheme = getThemeForCategory(item.category);
                    const opacity = scrollX.interpolate({
                        inputRange: [(index - 1) * width, index * width, (index + 1) * width],
                        outputRange: [0, 1, 0],
                        extrapolate: 'clamp',
                    });

                    return (
                        <Animated.View key={`bg-${item.id}`} style={[StyleSheet.absoluteFill, { opacity }]}>
                            <BackgroundRenderer themeColors={itemTheme} />
                        </Animated.View>
                    );
                })}
            </View>

            <Animated.View style={[styles.header, { opacity: headerOpacity, zIndex: 10 }]}>
                <View>
                    <Text style={styles.logo}>WhaDay</Text>
                    <View style={styles.dateSlot}>
                        {activeIndices.map((index) => {
                            const item = days[index];
                            const itemDate = new Date(now.getFullYear(), item.month - 1, item.day);
                            const dateText = itemDate.toLocaleDateString(dateLocale, {
                                weekday: 'long',
                                month: 'long',
                                day: 'numeric',
                            });
                            const opacity = scrollX.interpolate({
                                inputRange: [(index - 1) * width, index * width, (index + 1) * width],
                                outputRange: [0, 1, 0],
                                extrapolate: 'clamp',
                            });

                            return (
                                <Animated.Text
                                    key={`date-${item.id}`}
                                    style={[styles.dateText, { position: 'absolute', opacity }]}
                                >
                                    {dateText}
                                </Animated.Text>
                            );
                        })}
                    </View>
                </View>

                <View style={styles.headerActions}>
                    <TouchableOpacity
                        onPress={() => {
                            triggerLightImpact();
                            onOpenSettings();
                        }}
                        style={styles.iconBtn}
                        activeOpacity={0.6}
                    >
                        <Settings color="rgba(255,255,255,0.8)" size={22} strokeWidth={2} />
                    </TouchableOpacity>

                    <TouchableOpacity
                        onPress={() => {
                            triggerLightImpact();
                            onOpenCalendar();
                        }}
                        style={styles.iconBtn}
                        activeOpacity={0.6}
                    >
                        <View style={styles.gridIcon}>
                            {[...Array(9)].map((_, i) => (
                                <View key={i} style={styles.gridDot} />
                            ))}
                        </View>
                    </TouchableOpacity>
                </View>
            </Animated.View>

            <Animated.View
                style={[
                    styles.cardArea,
                    { transform: [{ translateY: cardTranslateY }], opacity: cardOpacity, zIndex: 5 },
                ]}
            >
                <Animated.FlatList
                    ref={flatListRef}
                    data={days}
                    keyExtractor={(item) => item.id}
                    horizontal
                    pagingEnabled
                    showsHorizontalScrollIndicator={false}
                    bounces
                    initialScrollIndex={initialIndexRef.current}
                    getItemLayout={(_, index) => ({ length: width, offset: width * index, index })}
                    onScroll={onScroll}
                    onMomentumScrollEnd={onMomentumScrollEnd}
                    scrollEventThrottle={16}
                    windowSize={3}
                    renderItem={({ item }) => (
                        <View style={styles.page}>
                            <GlassCard>
                                <Animated.Text style={[styles.emoji, { transform: [{ scale: emojiScale }] }]}>
                                    {item.emoji}
                                </Animated.Text>
                                <Text style={styles.title}>{item.title}</Text>
                                <Text style={styles.description}>{item.description}</Text>
                            </GlassCard>
                        </View>
                    )}
                />
            </Animated.View>

            <Animated.View style={[styles.buttonArea, { opacity: buttonOpacity, zIndex: 10 }]}>
                {activeIndices.map((index) => {
                    const item = days[index];
                    const itemTheme = getThemeForCategory(item.category);
                    const opacity = scrollX.interpolate({
                        inputRange: [(index - 1) * width, index * width, (index + 1) * width],
                        outputRange: [0, 1, 0],
                        extrapolate: 'clamp',
                    });

                    return (
                        <Animated.View
                            key={`btn-${item.id}`}
                            style={[styles.buttonLayer, { opacity }]}
                            pointerEvents={index === activeIndex ? 'auto' : 'none'}
                        >
                            <ActionButtons
                                primaryLabel={item.sharingHook ?? ui.shareOnStory}
                                secondaryLabel={ui.shareOnStory}
                                onPrimaryPress={handleShare}
                                onSecondaryPress={handleShare}
                                accentColor={itemTheme.accent}
                            />
                        </Animated.View>
                    );
                })}
            </Animated.View>

            <View style={styles.offscreen}>
                <ViewShot
                    ref={shareCardRef}
                    options={{ format: 'png', quality: 1, width: 1080, height: 1920 }}
                >
                    <LinearGradient colors={theme.gradient} style={styles.sCard}>
                        <View style={[styles.sBlob, { backgroundColor: theme.blob1, top: -100, right: -80 }]} />
                        <View style={[styles.sBlob, styles.sBlobMd, { backgroundColor: theme.blob2, bottom: 200, left: -60 }]} />
                        <View style={[styles.sBlob, styles.sBlobSm, { backgroundColor: theme.blob3, bottom: -40, right: 60 }]} />

                        <View style={styles.sGlass}>
                            <Text style={styles.sEmoji}>{displayEvent?.emoji ?? '✨'}</Text>
                            <Text style={styles.sTitle}>{displayEvent?.title ?? ui.noEventTitle}</Text>
                            <Text style={styles.sDesc}>{displayEvent?.description ?? ui.noEventDesc}</Text>
                        </View>

                        <View style={styles.sBrand}>
                            <View style={[styles.sBrandPill, { backgroundColor: theme.accent }]}>
                                <Text style={styles.sBrandW}>W</Text>
                            </View>
                            <Text style={styles.sBrandName}>WhaDay</Text>
                            <Text style={styles.sBrandDate}>
                                {new Date(now.getFullYear(), (displayEvent?.month || 1) - 1, displayEvent?.day || 1)
                                    .toLocaleDateString(dateLocale, { month: 'long', day: 'numeric' })}
                            </Text>
                        </View>
                    </LinearGradient>
                </ViewShot>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    header: {
        paddingTop: Platform.OS === 'ios' ? 70 : 50,
        paddingHorizontal: 28,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'flex-start',
    },
    logo: {
        fontSize: 32,
        fontWeight: '800',
        color: '#ffffff',
    },
    dateSlot: {
        height: 26,
        justifyContent: 'center',
    },
    dateText: {
        fontSize: 15,
        color: 'rgba(255,255,255,0.5)',
        marginTop: 4,
        fontWeight: '500',
    },
    headerActions: {
        flexDirection: 'row',
        gap: 12,
        alignItems: 'center',
        marginTop: 4,
    },
    iconBtn: {
        width: 44,
        height: 44,
        borderRadius: 14,
        backgroundColor: 'rgba(255,255,255,0.1)',
        borderWidth: 0.5,
        borderColor: 'rgba(255,255,255,0.2)',
        alignItems: 'center',
        justifyContent: 'center',
    },
    gridIcon: {
        width: 20,
        height: 20,
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 3,
        justifyContent: 'center',
        alignItems: 'center',
    },
    gridDot: {
        width: 4,
        height: 4,
        borderRadius: 2,
        backgroundColor: 'rgba(255,255,255,0.6)',
    },
    cardArea: {
        flex: 1,
        justifyContent: 'center',
    },
    page: {
        width,
        paddingHorizontal: 28,
        justifyContent: 'center',
    },
    emoji: {
        fontSize: 72,
        marginBottom: 16,
    },
    title: {
        fontSize: 30,
        fontWeight: '800',
        color: '#ffffff',
        textAlign: 'center',
        lineHeight: 36,
    },
    description: {
        fontSize: 16,
        color: 'rgba(255,255,255,0.7)',
        textAlign: 'center',
        lineHeight: 24,
        marginTop: 14,
        paddingHorizontal: 8,
        fontWeight: '400',
    },
    buttonArea: {
        height: 130,
    },
    buttonLayer: {
        position: 'absolute',
        width: '100%',
        bottom: 0,
    },
    offscreen: {
        position: 'absolute',
        left: -9999,
        top: -9999,
    },
    sCard: {
        width: 1080,
        height: 1920,
        justifyContent: 'center',
        alignItems: 'center',
    },
    sBlob: {
        position: 'absolute',
        width: 420,
        height: 420,
        borderRadius: 999,
        opacity: 0.3,
    },
    sBlobMd: {
        width: 300,
        height: 300,
    },
    sBlobSm: {
        width: 220,
        height: 220,
    },
    sGlass: {
        marginHorizontal: 36,
        borderRadius: 50,
        borderWidth: 1,
        borderColor: 'rgba(255,255,255,0.2)',
        backgroundColor: 'rgba(255,255,255,0.08)',
        paddingVertical: 80,
        paddingHorizontal: 56,
        alignItems: 'center',
    },
    sEmoji: {
        fontSize: 130,
        marginBottom: 36,
    },
    sTitle: {
        fontSize: 80,
        fontWeight: '800',
        color: '#ffffff',
        textAlign: 'center',
        lineHeight: 92,
        marginBottom: 28,
    },
    sDesc: {
        fontSize: 38,
        color: 'rgba(255,255,255,0.75)',
        textAlign: 'center',
        lineHeight: 56,
        fontWeight: '400',
    },
    sBrand: {
        position: 'absolute',
        bottom: 80,
        alignItems: 'center',
    },
    sBrandPill: {
        width: 56,
        height: 56,
        borderRadius: 18,
        alignItems: 'center',
        justifyContent: 'center',
        marginBottom: 10,
    },
    sBrandW: {
        fontSize: 30,
        fontWeight: '900',
        color: '#fff',
    },
    sBrandName: {
        fontSize: 30,
        fontWeight: '800',
        color: 'rgba(255,255,255,0.55)',
        letterSpacing: 2,
    },
    sBrandDate: {
        fontSize: 22,
        color: 'rgba(255,255,255,0.3)',
        marginTop: 4,
    },
});
