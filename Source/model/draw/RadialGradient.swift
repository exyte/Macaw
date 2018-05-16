open class RadialGradient: Gradient {

    open let cx: Double
    open let cy: Double
    open let fx: Double
    open let fy: Double
    open let r: Double

    public init(cx: Double = 0.5, cy: Double = 0.5, fx: Double = 0.5, fy: Double = 0.5, r: Double = 0.5, userSpace: Bool = false, stops: [Stop] = []) {
        self.cx = cx
        self.cy = cy
        self.fx = fx
        self.fy = fy
        self.r = r
        super.init(
            userSpace: userSpace,
            stops: stops
        )
    }
}
