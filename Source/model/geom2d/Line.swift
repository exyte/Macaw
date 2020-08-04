open class Line: Locus {

    public let x1: Double
    public let y1: Double
    public let x2: Double
    public let y2: Double

    public init(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    public init(x1: Double = 0, y1: Double = 0, x2: Double = 0, y2: Double = 0) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    override open func bounds() -> Rect {
        return Rect(x: min(x1, x2), y: min(y1, y2), w: abs(x1 - x2), h: abs(y1 - y2))
    }

    override open func toPath() -> Path {
        return MoveTo(x: x1, y: y1).lineTo(x: x2, y: y2).build()
    }

    override func equals<T>(other: T) -> Bool where T: Locus {
        guard let other = other as? Line else {
            return false
        }
        return x1 == other.x1
            && y1 == other.y1
            && x2 == other.x2
            && y2 == other.y2
    }
}
