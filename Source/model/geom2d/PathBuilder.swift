open class PathBuilder {

    public let segment: PathSegment
    public let rest: PathBuilder?

    public init(segment: PathSegment, rest: PathBuilder? = nil) {
        self.segment = segment
        self.rest = rest
    }

    open func moveTo(x: Double, y: Double) -> PathBuilder {
        return M(x, y)
    }

    open func lineTo(x: Double, y: Double) -> PathBuilder {
        return L(x, y)
    }

    open func cubicTo(x1: Double, y1: Double, x2: Double, y2: Double, x: Double, y: Double) -> PathBuilder {
        return C(x1, y1, x2, y2, x, y)
    }

    open func quadraticTo(x1: Double, y1: Double, x: Double, y: Double) -> PathBuilder {
        return Q(x1, y1, x, y)
    }

    open func arcTo(rx: Double, ry: Double, angle: Double, largeArc: Bool, sweep: Bool, x: Double, y: Double) -> PathBuilder {
        return A(rx, ry, angle, largeArc, sweep, x, y)
    }

    open func close() -> PathBuilder {
        return Z()
    }

    open func m(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .m, data: [x, y]), rest: self)
    }

    open func M(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .M, data: [x, y]), rest: self)
    }

    open func l(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .l, data: [x, y]), rest: self)
    }

    open func L(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .L, data: [x, y]), rest: self)
    }

    open func h(_ x: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .h, data: [x]), rest: self)
    }

    open func H(_ x: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .H, data: [x]), rest: self)
    }

    open func v(_ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .v, data: [y]), rest: self)
    }

    open func V(_ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .V, data: [y]), rest: self)
    }

    open func c(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .c, data: [x1, y1, x2, y2, x, y]), rest: self)
    }

    open func C(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .C, data: [x1, y1, x2, y2, x, y]), rest: self)
    }

    open func s(_ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .s, data: [x2, y2, x, y]), rest: self)
    }

    open func S(_ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .S, data: [x2, y2, x, y]), rest: self)
    }

    open func q(_ x1: Double, _ y1: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .q, data: [x1, y1, x, y]), rest: self)
    }

    open func Q(_ x1: Double, _ y1: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .Q, data: [x1, y1, x, y]), rest: self)
    }

    open func t(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .t, data: [x, y]), rest: self)
    }

    open func T(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .T, data: [x, y]), rest: self)
    }

    open func a(_ rx: Double, _ ry: Double, _ angle: Double, _ largeArc: Bool, _ sweep: Bool, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .a, data: [rx, ry, angle, boolToNum(largeArc), boolToNum(sweep), x, y]), rest: self)
    }

    open func A(_ rx: Double, _ ry: Double, _ angle: Double, _ largeArc: Bool, _ sweep: Bool, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .A, data: [rx, ry, angle, boolToNum(largeArc), boolToNum(sweep), x, y]), rest: self)
    }

    open func e(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ startAngle: Double, _ arcAngle: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .e, data: [x, y, w, h, startAngle, arcAngle]), rest: self)
    }

    open func E(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ startAngle: Double, _ arcAngle: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .E, data: [x, y, w, h, startAngle, arcAngle]), rest: self)
    }

    open func Z() -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .z), rest: self)
    }

    open func build() -> Path {
        var segments: [PathSegment] = []
        var builder: PathBuilder? = self
        while builder != nil {
            segments.append(builder!.segment)
            builder = builder!.rest
        }
        return Path(segments: segments.reversed())
    }

    fileprivate func boolToNum(_ value: Bool) -> Double {
        return value ? 1 : 0
    }

}
