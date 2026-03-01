import React, { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

export type BackgroundTheme = 'classic' | 'aurora' | 'grain' | 'topo' | 'atmosphere';

interface ThemeContextType {
    theme: BackgroundTheme;
    setTheme: (theme: BackgroundTheme) => Promise<void>;
    isLoading: boolean;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

const THEME_STORAGE_KEY = '@whaday_bg_theme';

export function ThemeProvider({ children }: { children: React.ReactNode }) {
    const [theme, setThemeState] = useState<BackgroundTheme>('classic');
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        const loadTheme = async () => {
            try {
                const storedTheme = await AsyncStorage.getItem(THEME_STORAGE_KEY);
                if (storedTheme) {
                    setThemeState(storedTheme as BackgroundTheme);
                }
            } catch (error) {
                console.error('Failed to load theme', error);
            } finally {
                setIsLoading(false);
            }
        };
        loadTheme();
    }, []);

    const setTheme = async (newTheme: BackgroundTheme) => {
        try {
            setThemeState(newTheme);
            await AsyncStorage.setItem(THEME_STORAGE_KEY, newTheme);
        } catch (error) {
            console.error('Failed to save theme', error);
        }
    };

    return (
        <ThemeContext.Provider value={{ theme, setTheme, isLoading }}>
            {children}
        </ThemeContext.Provider>
    );
}

export function useTheme() {
    const context = useContext(ThemeContext);
    if (context === undefined) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }
    return context;
}
