// Category-based gradient color themes
export interface ThemeColors {
    gradient: [string, string, string];
    blob1: string;
    blob2: string;
    blob3: string;
    accent: string;
}

const categoryThemes: Record<string, ThemeColors> = {
    wellness: {
        gradient: ['#0a1628', '#1a2744', '#0d1f3c'],
        blob1: '#6366f1',
        blob2: '#06b6d4',
        blob3: '#8b5cf6',
        accent: '#818cf8',
    },
    motivation: {
        gradient: ['#1a0a00', '#2d1810', '#1c0f08'],
        blob1: '#f59e0b',
        blob2: '#ef4444',
        blob3: '#f97316',
        accent: '#fbbf24',
    },
    nature: {
        gradient: ['#021a0e', '#0a2e1a', '#041f10'],
        blob1: '#10b981',
        blob2: '#06b6d4',
        blob3: '#34d399',
        accent: '#6ee7b7',
    },
    awareness: {
        gradient: ['#1a0a1e', '#2d1033', '#1c0820'],
        blob1: '#d946ef',
        blob2: '#a855f7',
        blob3: '#ec4899',
        accent: '#e879f9',
    },
    social: {
        gradient: ['#0f0c29', '#302b63', '#24243e'],
        blob1: '#a855f7',
        blob2: '#3b82f6',
        blob3: '#ec4899',
        accent: '#c084fc',
    },
    default: {
        gradient: ['#0f0c29', '#302b63', '#24243e'],
        blob1: '#a855f7',
        blob2: '#3b82f6',
        blob3: '#ec4899',
        accent: '#c084fc',
    },
};

export function getThemeForCategory(category?: string): ThemeColors {
    return categoryThemes[category ?? 'default'] ?? categoryThemes.default;
}
