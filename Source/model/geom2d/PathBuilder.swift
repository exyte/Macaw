import Foundation

open class PathBuilder {

	open let segment: PathSegment
	open let rest: PathBuilder?

	public init(segment: PathSegment, rest: PathBuilder? = nil) {
		self.segment = segment
		self.rest = rest
	}

    // GENERATED NOT
    open func moveTo(x: Double, y: Double) -> PathBuilder {
        return M(x, y)
    }

    // GENERATED NOT
    open func lineTo(x: Double, y: Double) -> PathBuilder {
        return L(x, y)
    }

    // GENERATED NOT
    open func cubicTo(x1: Double, y1: Double, x2: Double, y2: Double, x: Double, y: Double) -> PathBuilder {
        return C(x1, y1, x2, y2, x, y)
    }

    // GENERATED NOT
    open func quadraticTo(x1: Double, y1: Double, x: Double, y: Double) -> PathBuilder {
        return Q(x1, y1, x, y)
    }

    // GENERATED NOT
    open func arcTo(rx: Double, ry: Double, angle: Double, largeArc: Bool, sweep: Bool, x: Double, y: Double) -> PathBuilder {
        return A(rx, ry, angle, largeArc, sweep, x, y)
    }

    // GENERATED NOT
    open func close() -> PathBuilder {
        return Z()
    }

    // GENERATED NOT
    open func m(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .m, data: [x, y]), rest: self)
    }

    // GENERATED NOT
    open func M(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .M, data: [x, y]), rest: self)
    }

	// GENERATED NOT
	open func l(_ x: Double, _ y: Double) -> PathBuilder {
		return PathBuilder(segment: PathSegment(type: .l, data: [x, y]), rest: self)
	}

    // GENERATED NOT
    open func L(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .L, data: [x, y]), rest: self)
    }

    // GENERATED NOT
    open func h(_ x: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .h, data: [x]), rest: self)
    }

    // GENERATED NOT
    open func H(_ x: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .H, data: [x]), rest: self)
    }

    // GENERATED NOT
    open func v(_ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .v, data: [y]), rest: self)
    }

    // GENERATED NOT
    open func V(_ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .V, data: [y]), rest: self)
    }

    // GENERATED NOT
    open func c(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .c, data: [x1, y1, x2, y2, x, y]), rest: self)
    }

    // GENERATED NOT
    open func C(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .C, data: [x1, y1, x2, y2, x, y]), rest: self)
    }

    // GENERATED NOT
    open func s(_ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .s, data: [x2, y2, x, y]), rest: self)
    }

    // GENERATED NOT
    open func S(_ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .S, data: [x2, y2, x, y]), rest: self)
    }

    // GENERATED NOT
    open func q(_ x1: Double, _ y1: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .q, data: [x1, y1, x, y]), rest: self)
    }

    // GENERATED NOT
    open func Q(_ x1: Double, _ y1: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .Q, data: [x1, y1, x, y]), rest: self)
    }

    // GENERATED NOT
    open func t(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .t, data: [x, y]), rest: self)
    }

    // GENERATED NOT
    open func T(_ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .T, data: [x, y]), rest: self)
    }

    // GENERATED NOT
    open func a(_ rx: Double, _ ry: Double, _ angle: Double, _ largeArc: Bool, _ sweep: Bool, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .a, data: [rx, ry, angle, boolsToNum(largeArc, sweep: sweep), x, y]), rest: self)
    }

    // GENERATED NOT
    open func A(_ rx: Double, _ ry: Double, _ angle: Double, _ largeArc: Bool, _ sweep: Bool, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .A, data: [rx, ry, angle, boolsToNum(largeArc, sweep: sweep), x, y]), rest: self)
    }

    // GENERATED NOT
    open func Z() -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .z), rest: self)
    }

    // GENERATED NOT
    open func build() -> Path {
        var segments : [PathSegment] = []
        var builder : PathBuilder? = self
        while(builder != nil) {
            segments.append(builder!.segment)
            builder = builder!.rest
        }
        return Path(segments: segments.reversed())
    }

    // GENERATED NOT
    fileprivate func boolsToNum(_ largeArc: Bool, sweep: Bool) -> Double {
        return (largeArc ? 1 : 0) + (sweep ? 1 : 0) * 2;
    }

}
