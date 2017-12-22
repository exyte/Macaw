import Foundation

extension Locus {

    fileprivate func rectToPath(_ rect: Rect) -> Path {
        return MoveTo(x: rect.x, y: rect.y).lineTo(x: rect.x, y: rect.y + rect.h).lineTo(x: rect.x + rect.w, y: rect.y + rect.h).lineTo(x: rect.x + rect.w, y: rect.y).close().build()
    }

    fileprivate func circleToPath(_ circle: Circle) -> Path {
        return MoveTo(x: circle.cx, y: circle.cy).m(-circle.r, 0).a(circle.r, circle.r, 0.0, true, false, circle.r * 2.0, 0.0).a(circle.r, circle.r, 0.0, true, false, -(circle.r * 2.0), 0.0).build()
    }

    fileprivate func arcToPath(_ arc: Arc) -> Path {
        let rx = arc.ellipse.rx
        let ry = arc.ellipse.ry
        let cx = arc.ellipse.cx
        let cy = arc.ellipse.cy

        var delta = arc.extent
        if arc.shift == 0.0 && abs(arc.extent - .pi * 2.0) < 0.00001 {
            delta = .pi * 2.0 - 0.001
        }
        let theta1 = arc.shift

        let theta2 = theta1 + delta

        let x1 = cx + rx * cos(theta1)
        let y1 = cy + ry * sin(theta1)

        let x2 = cx + rx * cos(theta2)
        let y2 = cy + ry * sin(theta2)

        let largeArcFlag = abs(delta) > .pi ? true : false
        let sweepFlag = delta > 0.0 ? true : false

        return PathBuilder(segment: PathSegment(type: .M, data: [x1, y1])).A(rx, ry, 0.0, largeArcFlag, sweepFlag, x2, y2).build()
    }

    fileprivate func pointToPath(_ point: Point) -> Path {
        return MoveTo(x: point.x, y: point.y).lineTo(x: point.x, y: point.y).build()
    }

    fileprivate func pointsToPath(_ points: [Double], close: Bool = false) -> Path {
        var pb = PathBuilder(segment: PathSegment(type: .M, data: [points[0], points[1]]))
        if points.count > 2 {
            let parts = stride(from: 2, to: points.count, by: 2).map { Array(points[$0 ..< $0 + 2]) }
            for part in parts {
                pb = pb.lineTo(x: part[0], y: part[1])
            }
        }
        if close {
            pb = pb.close()
        }
        return pb.build()
    }

    public func toPath() -> Path {
        if let rect = self as? Rect {
            return rectToPath(rect)
        } else if let circle = self as? Circle {
            return circleToPath(circle)
        } else if let arc = self as? Arc {
            return arcToPath(arc)
        } else if let point = self as? Point {
            return MoveTo(x: point.x, y: point.y).lineTo(x: point.x, y: point.y).build()
        } else if let line = self as? Line {
            return MoveTo(x: line.x1, y: line.y1).lineTo(x: line.x2, y: line.y2).build()
        } else if let polygon = self as? Polygon {
            return pointsToPath(polygon.points, close: true)
        } else if let polyline = self as? Polyline {
            return pointsToPath(polyline.points)
        } else if let path = self as? Path {
            return path
        }
        fatalError("Unsupported locus: \(self)")
    }
}
