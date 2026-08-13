import React, { useEffect, useState } from 'react';
import HomeScreen from './src/screens/HomeScreen';
import CalendarScreen from './src/screens/CalendarScreen';
import SettingsScreen from './src/screens/SettingsScreen';
import type { DayEvent } from './src/hooks/useDayEvent';
import {
  requestNotificationPermission,
  scheduleEveningNotification,
  scheduleMorningNotification,
} from './src/utils/notifications';
import { ThemeProvider } from './src/hooks/ThemeContext';

type Screen = 'home' | 'calendar' | 'settings';

export default function App() {
  const [screen, setScreen] = useState<Screen>('home');
  const [selectedDay, setSelectedDay] = useState<DayEvent | null>(null);

  useEffect(() => {
    (async () => {
      const granted = await requestNotificationPermission();
      if (granted) {
        await scheduleMorningNotification();
        await scheduleEveningNotification();
      }
    })();
  }, []);

  return (
    <ThemeProvider>
      {screen === 'calendar' ? (
        <CalendarScreen
          onBack={() => setScreen('home')}
          selectedDay={selectedDay}
          onSelectDay={(event) => {
            setSelectedDay(event);
            setScreen('home');
          }}
        />
      ) : screen === 'settings' ? (
        <SettingsScreen
          onBack={() => setScreen('home')}
          eventCategory={selectedDay?.category}
        />
      ) : (
        <HomeScreen
          onOpenCalendar={() => setScreen('calendar')}
          onOpenSettings={() => setScreen('settings')}
          selectedDay={selectedDay}
          onSelectDay={(event) => setSelectedDay(event)}
        />
      )}
    </ThemeProvider>
  );
}
