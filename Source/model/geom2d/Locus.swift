open class Locus: Equatable {

    public init() {
    }

    open func bounds() -> Rect {
        Rect()
    }

    open func stroke(with: Stroke) -> Shape {
        Shape(form: self, stroke: with)
    }

    open func fill(with: Fill) -> Shape {
        Shape(form: self, fill: with)
    }

    open func fill(_ hex: Int) -> Shape {
        Shape(form: self, fill: Color(val: hex))
    }

    open func fill(_ fill: Fill) -> Shape {
        Shape(form: self, fill: fill)
    }

    open func stroke(fill: Fill = Color.black, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) -> Shape {
        Shape(form: self, stroke: Stroke(fill: fill, width: width, cap: cap, join: join, dashes: dashes))
    }

    open func stroke(color: Color, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) -> Shape {
        Shape(form: self, stroke: Stroke(fill: color, width: width, cap: cap, join: join, dashes: dashes))
    }

    open func stroke(color: Int, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) -> Shape {
        Shape(form: self, stroke: Stroke(fill: Color(color), width: width, cap: cap, join: join, dashes: dashes))
    }

    open func toPath() -> Path {
        fatalError("Unsupported locus: \(self)")
    }

    func equals<T>(other: T) -> Bool where T: Locus {
        fatalError("Equals can't be implemented for Locus")
    }
}

public func ==<T> (lhs: T, rhs: T) -> Bool where T: Locus {
    type(of: lhs) == type(of: rhs)
        && lhs.equals(other: rhs)
}
