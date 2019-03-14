open class Locus {

    public init() {
    }

    open func bounds() -> Rect {
        return Rect()
    }

    open func stroke(with: Stroke) -> Shape {
        return Shape(form: self, stroke: with)
    }

    open func fill(with: Fill) -> Shape {
        return Shape(form: self, fill: with)
    }

    open func stroke(fill: Fill = Color.black, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) -> Shape {
        return Shape(form: self, stroke: Stroke(fill: fill, width: width, cap: cap, join: join, dashes: dashes))
    }

    open func toPath() -> Path {
        if let point = self as? Point {
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
