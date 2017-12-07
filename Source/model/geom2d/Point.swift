import Foundation

open class Point: Locus {

    open let x: Double
    open let y: Double

    open static let origin: Point = Point( x: 0, y: 0 )

    public init(x: Double = 0, y: Double = 0) {
        self.x = x
        self.y = y
    }

    override open func bounds() -> Rect {
        return Rect(
            x: x,
            y: y,
            w: 0.0,
            h: 0.0)
    }

    // GENERATED NOT
    open func add(_ point: Point) -> Point {
        return Point(
            x: self.x + point.x,
            y: self.y + point.y)
    }
}
