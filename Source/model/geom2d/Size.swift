open class Size {

    public let w: Double
    public let h: Double

    public static let zero: Size = Size(w: 0, h: 0)

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
