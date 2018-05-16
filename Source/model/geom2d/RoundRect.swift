open class RoundRect: Locus {

    open let rect: Rect
    open let rx: Double
    open let ry: Double

    public init(rect: Rect, rx: Double = 0, ry: Double = 0) {
        self.rect = rect
        self.rx = rx
        self.ry = ry
    }

    override open func bounds() -> Rect {
        return rect
    }
}
