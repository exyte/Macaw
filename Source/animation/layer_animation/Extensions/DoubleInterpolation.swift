import Foundation

public protocol DoubleInterpolation: Interpolable {
    
}

extension Double: DoubleInterpolation {
	public func interpolate(endValue: Double, progress: Double) -> Double {
		return self + (endValue - self) * progress
	}

}
