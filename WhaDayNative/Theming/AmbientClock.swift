import Foundation

/// A shared time origin so every ambient background animation (across screens, across
/// simultaneously-crossfading layers) stays phase-locked and never jump-cuts on remount.
enum AmbientClock {
    static let epoch = Date()

    /// Smooth 0 -> 1 -> 0 ping-pong, seamless at the loop boundary for any period.
    static func pingPong(_ elapsed: TimeInterval, period: TimeInterval, phase: Double = 0) -> Double {
        (1 - cos((elapsed / period + phase) * 2 * .pi)) / 2
    }

    static func sine(_ elapsed: TimeInterval, period: TimeInterval, phase: Double = 0) -> Double {
        sin((elapsed / period + phase) * 2 * .pi)
    }

    static func cosine(_ elapsed: TimeInterval, period: TimeInterval, phase: Double = 0) -> Double {
        cos((elapsed / period + phase) * 2 * .pi)
    }
}
