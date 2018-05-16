open class Line: Locus {

    open let x1: Double
    open let y1: Double
    open let x2: Double
    open let y2: Double

    public init(x1: Double = 0, y1: Double = 0, x2: Double = 0, y2: Double = 0) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    override open func bounds() -> Rect {
        return Rect(
            x: min(x1, x2),
            y: min(y1, y2),
            w: abs(x1 - x2),
            h: abs(y1 - y2))
    }
}
