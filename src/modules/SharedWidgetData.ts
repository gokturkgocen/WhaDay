import SharedGroupPreferences from 'react-native-shared-group-preferences';
import { NativeModules } from 'react-native';
import type { BackgroundTheme } from '../hooks/ThemeContext';
import type { DayEvent } from '../hooks/useDayEvent';
import type { ThemeColors } from '../utils/themes';

const APP_GROUP_ID = 'group.com.gokturkgocen.whadayapp';

export const saveDayToWidget = async (
    data: DayEvent | null,
    bgTheme: BackgroundTheme,
    themeColors: ThemeColors,
) => {
    try {
        await Promise.all([
            SharedGroupPreferences.setItem('widgetEmoji', data?.emoji || '✨', APP_GROUP_ID),
            SharedGroupPreferences.setItem('widgetTitle', data?.title || 'WhaDay', APP_GROUP_ID),
            SharedGroupPreferences.setItem('widgetTheme', bgTheme || 'classic', APP_GROUP_ID),
            SharedGroupPreferences.setItem('widgetGradientStart', themeColors.gradient[0], APP_GROUP_ID),
            SharedGroupPreferences.setItem('widgetGradientMid', themeColors.gradient[1], APP_GROUP_ID),
            SharedGroupPreferences.setItem('widgetGradientEnd', themeColors.gradient[2], APP_GROUP_ID),
            SharedGroupPreferences.setItem('widgetBlob1', themeColors.blob1, APP_GROUP_ID),
            SharedGroupPreferences.setItem('widgetBlob2', themeColors.blob2, APP_GROUP_ID),
            SharedGroupPreferences.setItem('widgetBlob3', themeColors.blob3, APP_GROUP_ID),
            SharedGroupPreferences.setItem('widgetAccent', themeColors.accent, APP_GROUP_ID),
        ]);

        if (NativeModules.WidgetReloader) {
            NativeModules.WidgetReloader.reloadAllTimelines();
        }

        console.log('Widget data synced');
    } catch (errorCode) {
        console.log('Widget data sync failed:', errorCode);
    }
};
