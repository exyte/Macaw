public protocol TransformInterpolation: Interpolable {

}

extension Transform: TransformInterpolation {
    public func interpolate(_ endValue: Transform, progress: Double) -> Transform {
        return Transform(m11: self.m11.interpolate(endValue.m11, progress: progress),
                         m12: self.m12.interpolate(endValue.m12, progress: progress),
                         m21: self.m21.interpolate(endValue.m21, progress: progress),
                         m22: self.m22.interpolate(endValue.m22, progress: progress),
                         dx: self.dx.interpolate(endValue.dx, progress: progress),
                         dy: self.dy.interpolate(endValue.dy, progress: progress))
    }
}
