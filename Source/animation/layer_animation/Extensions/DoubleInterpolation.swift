public protocol DoubleInterpolation: Interpolable {

}

extension Double: DoubleInterpolation {
    public func interpolate(_ endValue: Double, progress: Double) -> Double {
        self + (endValue - self) * progress
    }
}
