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
}
