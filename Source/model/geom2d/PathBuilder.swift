import Foundation
import RxSwift

public class PathBuilder {

	public let segment: PathSegment
	public let rest: PathBuilder?

	public init(segment: PathSegment, rest: PathBuilder? = nil) {
		self.segment = segment
		self.rest = rest
	}

    // GENERATED NOT
    public func moveTo(x x: Double, y: Double) -> PathBuilder {
        return M(x, y)
    }

    // GENERATED NOT
    public func lineTo(x x: Double, y: Double) -> PathBuilder {
        return L(x, y)
    }

    // GENERATED NOT
    public func cubicTo(x1 x1: Double, y1: Double, x2: Double, y2: Double, x: Double, y: Double) -> PathBuilder {
        return C(x1, y1, x2, y2, x, y)
    }

    // GENERATED NOT
    public func quadraticTo(x1 x1: Double, y1: Double, x: Double, y: Double) -> PathBuilder {
        return Q(x1, y1, x, y)
    }

    // GENERATED NOT
    public func arcTo(rx: Double, _ ry: Double, angle: Double, largeArc: Bool, sweep: Bool, x: Double, y: Double) -> PathBuilder {
        return A(rx, ry, angle, largeArc, sweep, x, y)
    }

    // GENERATED NOT
    public func close() -> PathBuilder {
        return Z()
    }

    // GENERATED NOT
    public func m(x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .m, data: [x, y]), rest: self)
    }

    // GENERATED NOT
    public func M(x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .M, data: [x, y]), rest: self)
    }

	// GENERATED NOT
	public func l(x: Double, _ y: Double) -> PathBuilder {
		return PathBuilder(segment: PathSegment(type: .l, data: [x, y]), rest: self)
	}

    // GENERATED NOT
    public func L(x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .L, data: [x, y]), rest: self)
    }

    // GENERATED NOT
    public func h(x: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .h, data: [x]), rest: self)
    }

    // GENERATED NOT
    public func H(x: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .H, data: [x]), rest: self)
    }

    // GENERATED NOT
    public func v(y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .v, data: [y]), rest: self)
    }

    // GENERATED NOT
    public func V(y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .V, data: [y]), rest: self)
    }

    // GENERATED NOT
    public func c(x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .c, data: [x1, y1, x2, y2, x, y]), rest: self)
    }

    // GENERATED NOT
    public func C(x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .C, data: [x1, y1, x2, y2, x, y]), rest: self)
    }

    // GENERATED NOT
    public func s(_ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .s, data: [x2, y2, x, y]), rest: self)
    }

    // GENERATED NOT
    public func S(_ x2: Double, _ y2: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .S, data: [x2, y2, x, y]), rest: self)
    }

    // GENERATED NOT
    public func q(x1: Double, _ y1: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .q, data: [x1, y1, x, y]), rest: self)
    }

    // GENERATED NOT
    public func Q(x1: Double, _ y1: Double, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .Q, data: [x1, y1, x, y]), rest: self)
    }

    // GENERATED NOT
    public func t(x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .t, data: [x, y]), rest: self)
    }

    // GENERATED NOT
    public func T(x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .T, data: [x, y]), rest: self)
    }

    // GENERATED NOT
    public func a(rx: Double, _ ry: Double, _ angle: Double, _ largeArc: Bool, _ sweep: Bool, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .a, data: [rx, ry, angle, boolsToNum(largeArc, sweep: sweep), x, y]), rest: self)
    }

    // GENERATED NOT
    public func A(rx: Double, _ ry: Double, _ angle: Double, _ largeArc: Bool, _ sweep: Bool, _ x: Double, _ y: Double) -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .A, data: [rx, ry, angle, boolsToNum(largeArc, sweep: sweep), x, y]), rest: self)
    }

    // GENERATED NOT
    public func Z() -> PathBuilder {
        return PathBuilder(segment: PathSegment(type: .Z), rest: self)
    }

    // GENERATED NOT
    public func build() -> Path {
        var segments : [PathSegment] = []
        var builder : PathBuilder? = self
        while(builder != nil) {
            segments.append(builder!.segment)
            builder = builder!.rest
        }
        return Path(segments: segments.reverse())
    }

    // GENERATED NOT
    private func boolsToNum(largeArc: Bool, sweep: Bool) -> Double {
        return (largeArc ? 1 : 0) + (sweep ? 1 : 0) * 2;
    }

}
