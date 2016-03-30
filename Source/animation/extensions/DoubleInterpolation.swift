import Foundation

extension Double: InterpolatingType {
    public func interpolate(endValue: Double, progress: Double) -> Double {
        return self * (1.0 - progress) + endValue * progress
    }
}
