public protocol DoubleInterpolation: Interpolable {

}

extension Double: DoubleInterpolation {
    public func interpolate(_ endValue: Double, progress: Double) -> Double {
        return self + (endValue - self) * progress
    }
}

public final class StrokeEnd {
    var double: Double = 0

    public init(_ double: Double) {
        self.double = double
    }

    public static var zero: StrokeEnd {
        return StrokeEnd(0)
    }
}

public protocol StrokeEndInterpolation: Interpolable {

}

extension StrokeEnd: StrokeEndInterpolation {
    public func interpolate(_ endValue: StrokeEnd, progress: Double) -> StrokeEnd {
        return StrokeEnd(self.double + (endValue.double - self.double) * progress)
    }
}
