public enum FillRule {
    case nonzero, evenodd
}

open class Path: Locus {

    open let segments: [PathSegment]
    open let fillRule: FillRule

    public init(segments: [PathSegment] = [], fillRule: FillRule = .nonzero) {
        self.segments = segments
        self.fillRule = fillRule
    }

    override open func bounds() -> Rect {
        return pathBounds(self)!
    }
}
