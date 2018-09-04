open class Stop: Equatable {

    public let offset: Double
    public let color: Color

    public init(offset: Double = 0, color: Color) {
        self.color = color
        self.offset = max(0, min(1, offset))
    }
}

public func == (lhs: Stop, rhs: Stop) -> Bool {
    return lhs.offset == rhs.offset && lhs.color == rhs.color
}
