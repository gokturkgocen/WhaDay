import { Platform } from 'react-native';
import PushNotificationIOS from '@react-native-community/push-notification-ios';
import { getDeviceLanguage } from '../hooks/useDayEvent';

import enData from '../data/en.json';
import trData from '../data/tr.json';
import type { DayEvent } from '../hooks/useDayEvent';

type NotificationTag = 'morning' | 'evening';

const IS_IOS = Platform.OS === 'ios';

function getDays(): DayEvent[] {
    const lang = getDeviceLanguage();
    return lang === 'tr' ? trData : enData;
}

function getEventFor(month: number, day: number): DayEvent | null {
    return getDays().find((e) => e.month === month && e.day === day) ?? null;
}

function notificationId(tag: NotificationTag, event: DayEvent, date: Date) {
    const yyyy = date.getFullYear();
    const mm = `${date.getMonth() + 1}`.padStart(2, '0');
    const dd = `${date.getDate()}`.padStart(2, '0');
    return `${tag}-${event.id}-${yyyy}-${mm}-${dd}`;
}

function getScheduledNotifications(): Promise<any[]> {
    if (!IS_IOS) return Promise.resolve([]);

    return new Promise((resolve) => {
        PushNotificationIOS.getScheduledLocalNotifications((notifications) => {
            resolve(notifications);
        });
    });
}

async function cancelNotificationsByTag(tag: NotificationTag) {
    if (!IS_IOS) return;

    const notifications = await getScheduledNotifications();
    const identifiers = notifications
        .filter((notification) => notification.userInfo?.type === tag)
        .map((notification) => notification.id)
        .filter(Boolean);

    if (identifiers.length > 0) {
        PushNotificationIOS.removePendingNotificationRequests(identifiers);
    }
}

export async function requestNotificationPermission(): Promise<boolean> {
    if (!IS_IOS) return false;

    const permissions = await new Promise<{ alert?: boolean; badge?: boolean; sound?: boolean }>((resolve) => {
        PushNotificationIOS.checkPermissions(resolve);
    });

    if (permissions.alert || permissions.sound || permissions.badge) {
        return true;
    }

    const requested = await PushNotificationIOS.requestPermissions();
    return Boolean(requested.alert || requested.sound || requested.badge);
}

export async function scheduleMorningNotification() {
    if (!IS_IOS) return;

    const lang = getDeviceLanguage();
    await cancelNotificationsByTag('morning');

    const now = new Date();
    for (let i = 0; i < 7; i++) {
        const date = new Date(now);
        date.setDate(date.getDate() + i);

        const event = getEventFor(date.getMonth() + 1, date.getDate());
        if (!event) continue;

        const trigger = new Date(date);
        trigger.setHours(9, 0, 0, 0);
        if (trigger <= now) continue;

        PushNotificationIOS.addNotificationRequest({
            id: notificationId('morning', event, trigger),
            title: lang === 'tr' ? `${event.emoji} Bugün ${event.title}!` : `${event.emoji} Today is ${event.title}!`,
            body: event.description,
            fireDate: trigger,
            sound: 'default',
            userInfo: { dayId: event.id, type: 'morning' },
        });
    }
}

export async function scheduleEveningNotification() {
    if (!IS_IOS) return;

    const lang = getDeviceLanguage();
    await cancelNotificationsByTag('evening');

    const now = new Date();
    for (let i = 0; i < 7; i++) {
        const date = new Date(now);
        date.setDate(date.getDate() + i);

        const tomorrow = new Date(date);
        tomorrow.setDate(tomorrow.getDate() + 1);

        const event = getEventFor(tomorrow.getMonth() + 1, tomorrow.getDate());
        if (!event) continue;

        const trigger = new Date(date);
        trigger.setHours(21, 0, 0, 0);
        if (trigger <= now) continue;

        PushNotificationIOS.addNotificationRequest({
            id: notificationId('evening', event, trigger),
            title: lang === 'tr' ? `${event.emoji} Yarın ${event.title}!` : `${event.emoji} Tomorrow is ${event.title}!`,
            body: lang === 'tr' ? 'Yarın için hazırlan!' : "Don't forget about tomorrow!",
            fireDate: trigger,
            sound: 'default',
            userInfo: { dayId: event.id, type: 'evening' },
        });
    }
}

export async function cancelEveningNotifications() {
    await cancelNotificationsByTag('evening');
}

export async function cancelAllNotifications() {
    if (!IS_IOS) return;

    PushNotificationIOS.removeAllPendingNotificationRequests();
    PushNotificationIOS.removeAllDeliveredNotifications();
}
