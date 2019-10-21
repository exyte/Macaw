public protocol Interpolable {
    func interpolate(_ endValue: Self, progress: Double) -> Self
}
