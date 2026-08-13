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
    creative: {
        gradient: ['#171018', '#37213f', '#1f1028'],
        blob1: '#f472b6',
        blob2: '#fb7185',
        blob3: '#c084fc',
        accent: '#f9a8d4',
    },
    culture: {
        gradient: ['#14100b', '#33251a', '#1f1710'],
        blob1: '#f59e0b',
        blob2: '#d97706',
        blob3: '#f97316',
        accent: '#fbbf24',
    },
    fun: {
        gradient: ['#07121f', '#173554', '#0b2238'],
        blob1: '#38bdf8',
        blob2: '#22d3ee',
        blob3: '#a78bfa',
        accent: '#7dd3fc',
    },
    health: {
        gradient: ['#081817', '#123331', '#0c2425'],
        blob1: '#2dd4bf',
        blob2: '#14b8a6',
        blob3: '#22c55e',
        accent: '#5eead4',
    },
    lifestyle: {
        gradient: ['#17120d', '#322416', '#20170f'],
        blob1: '#fb923c',
        blob2: '#facc15',
        blob3: '#f97316',
        accent: '#fdba74',
    },
    science: {
        gradient: ['#07111f', '#122b45', '#081d33'],
        blob1: '#60a5fa',
        blob2: '#06b6d4',
        blob3: '#818cf8',
        accent: '#93c5fd',
    },
    tech: {
        gradient: ['#060b18', '#101f3b', '#081426'],
        blob1: '#38bdf8',
        blob2: '#6366f1',
        blob3: '#22d3ee',
        accent: '#67e8f9',
    },
    national: {
        gradient: ['#1c0709', '#3a1114', '#21090c'],
        blob1: '#ef4444',
        blob2: '#ffffff',
        blob3: '#dc2626',
        accent: '#fca5a5',
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
