// UI string translations
const strings: Record<string, Record<string, string>> = {
    en: {
        shareOnStory: 'Share on Story',
        noEventTitle: 'No event found',
        noEventDesc: "We don't have an event for today yet. Check back soon!",
    },
    tr: {
        shareOnStory: 'Hikayende Paylaş',
        noEventTitle: 'Bugün için etkinlik yok',
        noEventDesc: 'Bugüne ait henüz bir etkinlik eklenmedi. Yakında tekrar kontrol et!',
    },
};

export function getStrings(lang: string): Record<string, string> {
    return strings[lang] ?? strings.en;
}
