open class Size {

    open let w: Double
    open let h: Double

    public init(w: Double = 0, h: Double = 0) {
        self.w = w
        self.h = h
    }

    open func rect(at point: Point = Point.origin) -> Rect {
        return Rect(point: point, size: self)
    }
}

extension Size {
    public static func == (lhs: Size, rhs: Size) -> Bool {
        return lhs.w == rhs.w
            && lhs.h == rhs.h
    }
}
