public enum FillRule {
    case nonzero, evenodd
}

open class Path: Locus {

    public let segments: [PathSegment]
    public let fillRule: FillRule

    public init(segments: [PathSegment] = [], fillRule: FillRule = .nonzero) {
        self.segments = segments
        self.fillRule = fillRule
    }

    override open func bounds() -> Rect {
        return toCGPath().boundingBoxOfPath.toMacaw()
    }
}
