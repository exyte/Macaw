public protocol LocusInterpolation: Interpolable {

}

extension Locus: LocusInterpolation {
    public func interpolate(_ endValue: Locus, progress: Double) -> Self {
        return self
    }
}
