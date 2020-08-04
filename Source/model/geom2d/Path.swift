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

    override open func toPath() -> Path {
        return self
    }

    override func equals<T>(other: T) -> Bool where T: Locus {
        guard let other = other as? Path else {
            return false
        }
        return segments == other.segments
            && fillRule == other.fillRule
    }
}
