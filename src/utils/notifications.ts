import * as Notifications from 'expo-notifications';
import { getDeviceLanguage } from '../hooks/useDayEvent';

import enData from '../data/en.json';
import trData from '../data/tr.json';
import type { DayEvent } from '../hooks/useDayEvent';

// Bildirim handler (uygulama açıkken de göster)
Notifications.setNotificationHandler({
    handleNotification: async () => ({
        shouldShowAlert: true,
        shouldPlaySound: true,
        shouldSetBadge: false,
        shouldShowBanner: true,
        shouldShowList: true,
    }),
});

/** İzin iste */
export async function requestNotificationPermission(): Promise<boolean> {
    const { status: existing } = await Notifications.getPermissionsAsync();
    if (existing === 'granted') return true;

    const { status } = await Notifications.requestPermissionsAsync();
    return status === 'granted';
}

function getDays(): DayEvent[] {
    const lang = getDeviceLanguage();
    return lang === 'tr' ? trData : enData;
}

function getEventFor(month: number, day: number): DayEvent | null {
    return getDays().find((e) => e.month === month && e.day === day) ?? null;
}

/** Sabah 09:00 — "Bugün X günü!" bildirimi planla */
export async function scheduleMorningNotification() {
    const lang = getDeviceLanguage();

    // Önceki sabah bildirimlerini temizle
    await cancelNotificationsByTag('morning');

    // Sonraki 7 gün için planla
    const now = new Date();
    for (let i = 0; i < 7; i++) {
        const date = new Date(now);
        date.setDate(date.getDate() + i);
        const month = date.getMonth() + 1;
        const day = date.getDate();
        const event = getEventFor(month, day);
        if (!event) continue;

        const trigger = new Date(date);
        trigger.setHours(9, 0, 0, 0);

        // Eğer bugün ve saat 9'u geçtiyse atla
        if (trigger <= now) continue;

        await Notifications.scheduleNotificationAsync({
            content: {
                title: lang === 'tr' ? `${event.emoji} Bugün ${event.title}!` : `${event.emoji} Today is ${event.title}!`,
                body: event.description,
                data: { dayId: event.id, type: 'morning' },
            },
            trigger: { type: Notifications.SchedulableTriggerInputTypes.DATE, date: trigger },
        });
    }
}

/** Akşam 21:00 — "Yarın X günü, unutma!" bildirimi planla */
export async function scheduleEveningNotification() {
    const lang = getDeviceLanguage();

    await cancelNotificationsByTag('evening');

    const now = new Date();
    for (let i = 0; i < 7; i++) {
        const date = new Date(now);
        date.setDate(date.getDate() + i);

        // Yarının etkinliğini al
        const tomorrow = new Date(date);
        tomorrow.setDate(tomorrow.getDate() + 1);
        const month = tomorrow.getMonth() + 1;
        const day = tomorrow.getDate();
        const event = getEventFor(month, day);
        if (!event) continue;

        const trigger = new Date(date);
        trigger.setHours(21, 0, 0, 0);

        if (trigger <= now) continue;

        await Notifications.scheduleNotificationAsync({
            content: {
                title: lang === 'tr' ? `${event.emoji} Yarın ${event.title}!` : `${event.emoji} Tomorrow is ${event.title}!`,
                body: lang === 'tr' ? 'Yarın için hazırlan!' : "Don't forget about tomorrow!",
                data: { dayId: event.id, type: 'evening' },
            },
            trigger: { type: Notifications.SchedulableTriggerInputTypes.DATE, date: trigger },
        });
    }
}

/** Belirli tag'daki bildirimleri iptal et */
async function cancelNotificationsByTag(tag: string) {
    const all = await Notifications.getAllScheduledNotificationsAsync();
    for (const n of all) {
        if ((n.content.data as any)?.type === tag) {
            await Notifications.cancelScheduledNotificationAsync(n.identifier);
        }
    }
}

/** Akşam bildirimlerini tamamen kapat */
export async function cancelEveningNotifications() {
    await cancelNotificationsByTag('evening');
}

/** Tüm bildirimleri iptal et */
export async function cancelAllNotifications() {
    await Notifications.cancelAllScheduledNotificationsAsync();
}
