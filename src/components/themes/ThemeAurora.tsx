import React from 'react';
import { View, Animated, StyleSheet, Dimensions } from 'react-native';
import { BlurView } from 'expo-blur';
import { timer12s, timer15s, timer18s } from './GlobalAnim';

const { width, height } = Dimensions.get('window');

interface AuroraProps {
    blob1Color: string;
    blob2Color: string;
    blob3Color: string;
}

function MovingBlob({ color, size, startX, startY, moveX, moveY, timer }: any) {
    const inputs = [];
    const outX = [];
    const outY = [];

    // 0..1 linear time -> perfectly smooth sine ping-pong
    for (let i = 0; i <= 40; i++) {
        const t = i / 40;
        inputs.push(t);
        const sineProgress = (1 - Math.cos(t * Math.PI * 2)) / 2;
        outX.push(sineProgress * moveX);
        outY.push(sineProgress * moveY);
    }

    const translateX = timer.interpolate({ inputRange: inputs, outputRange: outX });
    const translateY = timer.interpolate({ inputRange: inputs, outputRange: outY });

    return (
        <Animated.View
            style={[
                styles.blob,
                {
                    backgroundColor: color,
                    width: size,
                    height: size,
                    left: startX,
                    top: startY,
                    transform: [{ translateX }, { translateY }],
                },
            ]}
        />
    );
}

export default function ThemeAurora({ blob1Color, blob2Color, blob3Color }: AuroraProps) {
    return (
        <View style={StyleSheet.absoluteFill} pointerEvents="none">
            <MovingBlob color={blob1Color} size={width * 1.5} startX={-width * 0.25} startY={-height * 0.2} moveX={width * 0.3} moveY={height * 0.2} timer={timer12s} />
            <MovingBlob color={blob2Color} size={width * 1.2} startX={width * 0.1} startY={height * 0.4} moveX={-width * 0.4} moveY={-height * 0.3} timer={timer15s} />
            <MovingBlob color={blob3Color} size={width} startX={-width * 0.2} startY={height * 0.6} moveX={width * 0.5} moveY={-height * 0.1} timer={timer18s} />

            <BlurView intensity={100} tint="systemChromeMaterialDark" style={StyleSheet.absoluteFill} />
            <BlurView intensity={100} tint="default" style={StyleSheet.absoluteFill} />
        </View>
    );
}

const styles = StyleSheet.create({
    blob: {
        position: 'absolute',
        borderRadius: 9999,
        opacity: 0.6,
    },
});
