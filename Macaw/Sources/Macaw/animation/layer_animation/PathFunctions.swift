import Foundation

typealias Func2D = ((_ t: Double) -> (Point))

func BezierFunc2D(_ t: Double, p0: Point, p1: Point, p2: Point, p3: Point) -> Point {
    return Point(
        x: polynom3(t, p0: p0.x, p1: p1.x, p2: p2.x, p3: p3.x),
        y: polynom3(t, p0: p0.y, p1: p1.y, p2: p2.y, p3: p3.y))
}

func polynom3(_ t: Double, p0: Double, p1: Double, p2: Double, p3: Double) -> Double {
    let t1 = 1.0 - t
    return pow(t1, 3.0) * p0 + 3.0 * t * pow(t1, 2.0) * p1 + 3.0 * t * t * t1 * p2 + pow(t, 3.0) * p3
}
