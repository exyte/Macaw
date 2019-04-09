import Foundation

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
