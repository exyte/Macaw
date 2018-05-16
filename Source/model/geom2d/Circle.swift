open class Circle: Locus {

    open let cx: Double
    open let cy: Double
    open let r: Double

    public init(cx: Double = 0, cy: Double = 0, r: Double = 0) {
        self.cx = cx
        self.cy = cy
        self.r = r
    }

    override open func bounds() -> Rect {
        return Rect(
            x: cx - r,
            y: cy - r,
            w: r * 2.0,
            h: r * 2.0)
    }

    open func arc(shift: Double, extent: Double) -> Arc {
        return Arc(ellipse: Ellipse(cx: cx, cy: cy, rx: r, ry: r), shift: shift, extent: extent)
    }
}
