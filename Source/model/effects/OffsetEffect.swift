open class OffsetEffect: Effect {

    open let dx: Double
    open let dy: Double

    public init(dx: Double = 0, dy: Double = 0, input: Effect?) {
        self.dx = dx
        self.dy = dy
        super.init(input: input)
    }
}
