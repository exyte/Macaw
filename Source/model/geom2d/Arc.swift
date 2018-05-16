open class Arc: Locus {

    open let ellipse: Ellipse
    open let shift: Double
    open let extent: Double

    public init(ellipse: Ellipse, shift: Double = 0, extent: Double = 0) {
        self.ellipse = ellipse
        self.shift = shift
        self.extent = extent
    }

    override open func bounds() -> Rect {
        return Rect(
            x: ellipse.cx - ellipse.rx,
            y: ellipse.cy - ellipse.ry,
            w: ellipse.rx * 2.0,
            h: ellipse.ry * 2.0)
    }
}
