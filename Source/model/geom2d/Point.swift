import Foundation

open class Point: Locus {

    public let x: Double
    public let y: Double

    public static let origin = Point(0, 0)

    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }

    public init(x: Double = 0, y: Double = 0) {
        self.x = x
        self.y = y
    }

    override open func bounds() -> Rect {
        return Rect(x: x, y: y, w: 0.0, h: 0.0)
    }

    open func add(_ point: Point) -> Point {
        return Point( x: x + point.x, y: y + point.y)
    }

    open func rect(size: Size) -> Rect {
        return Rect(point: self, size: size)
    }

    open func distance(to point: Point) -> Double {
        let dx = point.x - x
        let dy = point.y - y
        return sqrt(dx * dx + dy * dy)
    }

    override open func toPath() -> Path {
        return MoveTo(x: x, y: y).lineTo(x: x, y: y).build()
    }

    override func equals<T>(other: T) -> Bool where T: Locus {
        guard let other = other as? Point else {
            return false
        }
        return x == other.y
            && y == other.y
    }
}

extension Point {

    public static func - (lhs: Point, rhs: Point) -> Size {
        return Size(w: lhs.x - rhs.x, h: lhs.y - rhs.y)
    }
}
