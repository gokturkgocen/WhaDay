import enData from '../data/en.json';
import trData from '../data/tr.json';
import { getLocales } from 'react-native-localize';

export interface DayEvent {
    id: string;
    month: number;
    day: number;
    title: string;
    description: string;
    emoji: string;
    category: string;
    icon: string;
    sharingHook: string;
}

const dataMap: Record<string, DayEvent[]> = {
    en: enData,
    tr: trData,
};

export function getDeviceLanguage(): string {
    const locales = getLocales();
    const lang = locales[0]?.languageCode ?? 'en';
    return dataMap[lang] ? lang : 'en';
}

export function getDateLocale(): string {
    const lang = getDeviceLanguage();
    if (lang === 'tr') return 'tr-TR';
    return 'en-US';
}

export function useTodayEvent(): DayEvent | null {
    const lang = getDeviceLanguage();
    const days = dataMap[lang];
    const now = new Date();
    const month = now.getMonth() + 1;
    const day = now.getDate();

    return days.find((e) => e.month === month && e.day === day) ?? null;
}

export function getEventForDate(month: number, day: number): DayEvent | null {
    const lang = getDeviceLanguage();
    const days = dataMap[lang];
    return days.find((e) => e.month === month && e.day === day) ?? null;
}
