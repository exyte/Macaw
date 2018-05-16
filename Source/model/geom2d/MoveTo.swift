open class MoveTo: PathBuilder {

    public init(x: Double, y: Double) {
        super.init(segment: PathSegment(type: .M, data: [x, y]))
    }
}
