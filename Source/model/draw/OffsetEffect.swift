open class OffsetEffect: Effect {

    public let dx: Double
    public let dy: Double

    public init(dx: Double = 0, dy: Double = 0, input: Effect? = nil) {
        self.dx = dx
        self.dy = dy
        super.init(input: input)
    }
}
