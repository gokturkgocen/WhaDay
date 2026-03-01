import React from 'react';
import { View, StyleSheet, Image, Dimensions } from 'react-native';

const { width, height } = Dimensions.get('window');

// A 64x64 repeating film grain texture (base64 encoded PNG)
const NOISE_BASE64 = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAMAAACdt4HsAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAA/1BMVEUAAADv7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+///85jIt0AAAAXnRSTlMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD8oGxEAAAABYktHQLJ77b5NAAAAB3RJTUUH5gIMDTExdVNPTAAAAiJJREFUWMOtll10EkEUhU9Q1MDAQBQM/EAFERUFBSX1QkUFJSU1lZSUlJSUlJSU1NRLS0tLS0tL6/W0Xn/vrO7MzO7sO/+27s1Z+1yYcw9mRkZGAAAAwP9hZGRkZP4fRgbA8P3v3z//wPDw8PDPbwYGBga/A4ODA+D/7+//+AcG/gH4//kLBvoHBoD/gYH+B36DBz0Y4L8//cAA8PvvD/R7wM9fMNAPAeAX/AwA4JfhwW8P+B4A/f0Q6Bv4FfSD38CAn2AwAAwM+H2DPr8BAwP9fvj1G/ADMAAMAAAMAD0Q8EPwox/8BoZ9P+iBPngz0AfD7wf0e/xDA98gA3xAf9AA+H1AAyDgv5EBAwAAAQAAAAAAEAAAAAAQAAAAABAAAAAAEAIAAQAAAAACAAAAAAIAAAAAAgAAAAACAAAAAAIAAAACAAAAAAIAAAAAAgAAAAACAAAAAAIAAAAAhAAAAACEAAAAAIQAAAAAhAAAAACEAAAAAAQAAAAABAAAAAAIAAAAAAgAAAAACAAAAAAIAAAACAAAAAAIAAAAAAgAAAAACAAAAAAIAAAAAAhAAAAACEAAAAAIQAAAAAhAAAAACEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABA//8ABz/qQ8s/6kQAAAAASUVORK5CYII=';

export default function ThemeGrain() {
    return (
        <View style={StyleSheet.absoluteFill} pointerEvents="none">
            <View style={[StyleSheet.absoluteFill, { backgroundColor: 'rgba(0,0,0,0.6)' }]} />

            <Image
                source={{ uri: NOISE_BASE64 }}
                style={{
                    width: width,
                    height: height,
                    opacity: 0.15,
                }}
                resizeMode="repeat"
            />
        </View>
    );
}
