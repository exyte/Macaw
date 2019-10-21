open class MoveTo: PathBuilder {

    public init(_ x: Double, _ y: Double) {
        super.init(segment: PathSegment(type: .M, data: [x, y]))
    }

    public init(x: Double, y: Double) {
        super.init(segment: PathSegment(type: .M, data: [x, y]))
    }
}
