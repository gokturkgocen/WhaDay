import React from 'react';
import { View, Animated, StyleSheet, Dimensions } from 'react-native';
import { timer7s, timer8s, timer10s } from './themes/GlobalAnim';

const { width, height } = Dimensions.get('window');

interface BlobConfig {
    color: string;
    size: number;
    x: number;
    y: number;
    timer: Animated.Value;
}

interface AnimatedBackgroundProps {
    blob1Color: string;
    blob2Color: string;
    blob3Color: string;
}

function AnimatedBlob({ color, size, x, y, timer }: BlobConfig) {
    const inputs = [];
    const outputs = [];
    // 0..1 linear time to 0.95 -> 1.08 -> 0.95 smooth sine ping-pong
    for (let i = 0; i <= 40; i++) {
        const t = i / 40;
        inputs.push(t);
        const scaleProgress = (1 - Math.cos(t * Math.PI * 2)) / 2;
        outputs.push(0.95 + scaleProgress * (1.08 - 0.95));
    }

    const scale = timer.interpolate({
        inputRange: inputs,
        outputRange: outputs,
    });

    return (
        <Animated.View
            style={[
                styles.blob,
                {
                    backgroundColor: color,
                    width: size,
                    height: size,
                    left: x,
                    top: y,
                    transform: [{ scale }],
                },
            ]}
        />
    );
}

export default function AnimatedBackground({ blob1Color, blob2Color, blob3Color }: AnimatedBackgroundProps) {
    return (
        <View style={StyleSheet.absoluteFill} pointerEvents="none">
            <AnimatedBlob color={blob1Color} size={280} x={width - 160} y={-80} timer={timer8s} />
            <AnimatedBlob color={blob2Color} size={200} x={-40} y={height - 280} timer={timer10s} />
            <AnimatedBlob color={blob3Color} size={150} x={width - 190} y={height - 150} timer={timer7s} />
        </View>
    );
}

const styles = StyleSheet.create({
    blob: {
        position: 'absolute',
        borderRadius: 999,
        opacity: 0.3,
    },
});
