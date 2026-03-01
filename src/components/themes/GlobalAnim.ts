import { Animated, Easing } from 'react-native';

const createTimer = () => new Animated.Value(0);

// Ortak senkronize zamanlayıcılar (Singletons)
// Tüm sayfalar arası geçişlerde aynı objeleri dinledikleri için 0'dan başlama olmaz.
export const timer4s = createTimer();
export const timer7s = createTimer();
export const timer8s = createTimer();
export const timer9s = createTimer();
export const timer10s = createTimer();
export const timer12s = createTimer();
export const timer15s = createTimer();
export const timer18s = createTimer();
export const timer40s = createTimer();

let isStarted = false;

export const startGlobalAnimations = () => {
    if (isStarted) return;
    isStarted = true;

    const startLoop = (t: Animated.Value, duration: number) => {
        Animated.loop(
            Animated.timing(t, {
                toValue: 1,
                duration,
                easing: Easing.linear,
                useNativeDriver: true,
            })
        ).start();
    };

    startLoop(timer4s, 4000);
    startLoop(timer7s, 7000);
    startLoop(timer8s, 8000);
    startLoop(timer9s, 9000);
    startLoop(timer10s, 10000);
    startLoop(timer12s, 12000);
    startLoop(timer15s, 15000);
    startLoop(timer18s, 18000);
    startLoop(timer40s, 40000);
};

export const inOutSineCache: number[] = [];
for (let i = 0; i <= 40; i++) {
    const t = i / 40;
    inOutSineCache.push(-(Math.cos(Math.PI * t) - 1) / 2);
}
