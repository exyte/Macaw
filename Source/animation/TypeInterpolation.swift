import Foundation

public protocol InterpolatingType {
    func interpolate(endValue: Self, progress: Double) -> Self
}

