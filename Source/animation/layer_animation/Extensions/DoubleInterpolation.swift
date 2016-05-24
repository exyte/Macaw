import Foundation

extension Double: Interpolable {
	public func interpolate(endValue: Double, progress: Double) -> Double {
		return self + (endValue - self) * progress
	}
}
