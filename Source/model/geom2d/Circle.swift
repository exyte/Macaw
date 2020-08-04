open class Circle: Locus {

    public let cx: Double
    public let cy: Double
    public let r: Double

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

    override open func toPath() -> Path {
        return MoveTo(x: cx, y: cy).m(-r, 0).a(r, r, 0.0, true, false, r * 2.0, 0.0).a(r, r, 0.0, true, false, -(r * 2.0), 0.0).build()
    }

    override func equals<T>(other: T) -> Bool where T: Locus {
        guard let other = other as? Circle else {
            return false
        }
        return cx == other.cx
            && cy == other.cy
            && r == other.r
    }
}
