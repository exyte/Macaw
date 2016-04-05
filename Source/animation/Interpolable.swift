import Foundation

public protocol Interpolable {
    func interpolate(endValue: Self, progress: Double) -> Self
}

