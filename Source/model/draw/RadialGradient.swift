open class RadialGradient: Gradient {

    public let cx: Double
    public let cy: Double
    public let fx: Double
    public let fy: Double
    public let r: Double

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

    override func equals<T>(other: T) -> Bool where T: RadialGradient {
        return super.equals(other: other) && cx == other.cx && cy == other.cy && fx == other.fx && fy == other.fy && r == other.r
    }
}
