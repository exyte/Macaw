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

    override func equals<T>(other: T) -> Bool where T: Fill {
        guard let other = other as? RadialGradient else {
            return false
        }
        let cxEquals = cx == other.cx
        let cyEquals = cy == other.cy
        let fxEquals = fx == other.fx
        let fyEquals = fy == other.fy
        let rEquals = r == other.r
        return super.equals(other: other) && cxEquals && cyEquals && fxEquals && fyEquals && rEquals
    }
}
