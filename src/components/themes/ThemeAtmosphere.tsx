import React, { useEffect, useState } from 'react';
import { View, Animated, StyleSheet, Dimensions } from 'react-native';
import { timer4s, timer15s, timer18s } from './GlobalAnim';

const { width, height } = Dimensions.get('window');

// Global Sabitler (Deterministic Random)
// Sayfalar arasında yıldızların konum/boyut/zamanlamasının atlama yapmadan devam etmesi için sabitlenmiştir.
const STATIC_STARS = Array.from({ length: 15 }).map((_, i) => ({
    id: i,
    x: (Math.sin(i * 3.14) * 0.5 + 0.5) * width,
    y: (Math.cos(i * 7.42) * 0.5 + 0.5) * (height * 0.7),
    size: (Math.sin(i * 5.91) * 0.5 + 0.5) * 2 + 1,
    offsetP: Math.abs(Math.cos(i * 2.33)) // 0 to 1
}));

const STATIC_RAYS = [
    { id: 1, angle: -15, timer: timer18s, offsetP: 0 },
    { id: 2, angle: 25, timer: timer15s, offsetP: 0.35 },
];

function Star({ x, y, size, offsetP }: any) {
    const inputs = [];
    const outputs = [];
    // 0..1 linear global time -> smooth blinking sine wave
    for (let i = 0; i <= 40; i++) {
        const t = i / 40;
        inputs.push(t);
        const val = 0.35 + 0.25 * Math.sin((t + offsetP) * Math.PI * 2);
        outputs.push(val);
    }
    const opacity = timer4s.interpolate({ inputRange: inputs, outputRange: outputs });

    return (
        <Animated.View
            style={{
                position: 'absolute',
                left: x,
                top: y,
                width: size,
                height: size,
                backgroundColor: 'white',
                borderRadius: size / 2,
                opacity,
            }}
        />
    );
}

function LightRay({ angle, timer, offsetP }: any) {
    const inputs = [];
    const outputs = [];
    for (let i = 0; i <= 40; i++) {
        const t = i / 40;
        inputs.push(t);
        // 0 to 0.12 ping-pong ray
        const val = 0.06 - 0.06 * Math.cos((t + offsetP) * Math.PI * 2);
        outputs.push(Math.max(0, val));
    }
    const opacity = timer.interpolate({ inputRange: inputs, outputRange: outputs });

    return (
        <Animated.View
            style={[
                styles.ray,
                {
                    opacity,
                    transform: [
                        { rotate: `${angle}deg` },
                        { translateY: -height * 0.2 },
                    ],
                },
            ]}
        />
    );
}

export default function ThemeAtmosphere() {
    const [isNight, setIsNight] = useState(false);

    useEffect(() => {
        const hour = new Date().getHours();
        setIsNight(hour < 6 || hour > 19);
    }, []);

    return (
        <View style={StyleSheet.absoluteFill} pointerEvents="none">
            <View style={[StyleSheet.absoluteFill, { backgroundColor: isNight ? 'rgba(0,0,15,0.6)' : 'rgba(255,255,255,0.1)' }]} />

            {isNight ? (
                STATIC_STARS.map((el) => (
                    <Star key={el.id} x={el.x} y={el.y} size={el.size} offsetP={el.offsetP} />
                ))
            ) : (
                STATIC_RAYS.map((el) => (
                    <LightRay key={el.id} angle={el.angle} timer={el.timer} offsetP={el.offsetP} />
                ))
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    ray: {
        position: 'absolute',
        left: width / 2 - 150,
        top: -height * 0.3,
        width: 300,
        height: height * 1.5,
        backgroundColor: 'white',
        borderRadius: 150,
    },
});
