open class Rect: Locus {

    public let x: Double
    public let y: Double
    public let w: Double
    public let h: Double

    public init(_ x: Double, _ y: Double, _ w: Double, _ h: Double) {
        self.x = x
        self.y = y
        self.w = w
        self.h = h
    }

    public init(x: Double = 0, y: Double = 0, w: Double = 0, h: Double = 0) {
        self.x = x
        self.y = y
        self.w = w
        self.h = h
    }

    public init(point: Point, size: Size) {
        self.x = point.x
        self.y = point.y
        self.w = size.w
        self.h = size.h
    }

    override open func bounds() -> Rect {
        return self
    }

    open func round(rx: Double, ry: Double) -> RoundRect {
        return RoundRect(rect: self, rx: rx, ry: ry)
    }

    public func round(r: Double) -> RoundRect {
        return RoundRect(rect: self, rx: r, ry: r)
    }

    open func center() -> Point {
        return Point(x: x + w / 2, y: y + h / 2)
    }

    open func contains(locus: Locus) -> Bool {
        return false
    }

    class func zero() -> Rect {
        return Rect(x: 0.0, y: 0.0, w: 0.0, h: 0.0)
    }

    open func move(offset: Point) -> Rect {
        return Rect(
            x: self.x + offset.x,
            y: self.y + offset.y,
            w: self.w,
            h: self.h)
    }

    open func union(rect: Rect) -> Rect {
        return Rect(
            x: min(self.x, rect.x),
            y: min(self.y, rect.y),
            w: max(self.x + self.w, rect.x + rect.w) - min(self.x, rect.x),
            h: max(self.y + self.h, rect.y + rect.h) - min(self.y, rect.y))
    }

    open func size() -> Size {
        return Size(w: w, h: h)
    }

    override open func toPath() -> Path {
        return MoveTo(x: x, y: y).lineTo(x: x, y: y + h).lineTo(x: x + w, y: y + h).lineTo(x: x + w, y: y).close().build()
    }
}

extension Rect {
    public static func == (lhs: Rect, rhs: Rect) -> Bool {
        return lhs.x == rhs.x
            && lhs.y == rhs.y
            && lhs.w == rhs.w
            && lhs.h == rhs.h
    }
}
