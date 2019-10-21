public protocol ContentsInterpolation: Interpolable {

}

extension Array: ContentsInterpolation {
    public func interpolate(_ endValue: Array, progress: Double) -> Array {
        return self
    }
}
