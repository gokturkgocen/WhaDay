import React from 'react';
import { View, Animated, StyleSheet, Dimensions } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { timer40s } from './GlobalAnim';

const { width, height } = Dimensions.get('window');

// A large, elegant abstract wave/topo path
const TOPO_PATH = `
M-100,200 Q150,50 400,250 T900,150 T1400,300
M-100,300 Q200,100 500,350 T1000,200 T1500,400
M-100,400 Q250,150 600,450 T1100,250 T1600,500
M-100,500 Q300,200 700,550 T1200,300 T1700,600
M-100,600 Q350,250 800,650 T1300,350 T1800,700
`;

export default function ThemeTopo() {
    // 0..1 to 0..-500
    const translateX = timer40s.interpolate({
        inputRange: [0, 1],
        outputRange: [0, -500],
    });

    return (
        <View style={StyleSheet.absoluteFill} pointerEvents="none">
            <View style={[StyleSheet.absoluteFill, { backgroundColor: 'rgba(0,0,0,0.4)' }]} />

            <Animated.View style={[StyleSheet.absoluteFill, { transform: [{ translateX }] }]}>
                <Svg width={width + 1000} height={height} viewBox={`0 0 ${width + 1000} ${height}`}>
                    <Path
                        d={TOPO_PATH}
                        fill="none"
                        stroke="rgba(255,255,255,0.08)"
                        strokeWidth="1.5"
                    />
                </Svg>
            </Animated.View>
        </View>
    );
}
