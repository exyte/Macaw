import Foundation

open class Size {

    public let w: Double
    public let h: Double

    public static let zero = Size(0, 0)

    public init(_ w: Double, _ h: Double) {
        self.w = w
        self.h = h
    }

    public init(w: Double = 0, h: Double = 0) {
        self.w = w
        self.h = h
    }

    open func rect(at point: Point = Point.origin) -> Rect {
        return Rect(point: point, size: self)
    }

    open func angle() -> Double {
        return atan2(h, w)
    }

}

extension Size {

    public static func == (lhs: Size, rhs: Size) -> Bool {
        return lhs.w == rhs.w && lhs.h == rhs.h
    }

    public static func + (lhs: Size, rhs: Size) -> Size {
        return Size(w: lhs.w + rhs.w, h: lhs.h + rhs.h)
    }

    public static func - (lhs: Size, rhs: Size) -> Size {
        return Size(w: lhs.w - rhs.w, h: lhs.h - rhs.h)
    }

}
