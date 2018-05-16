open class Stop {

    open let offset: Double
    open let color: Color

    public init(offset: Double = 0, color: Color) {
        self.color = color
        self.offset = max(0, min(1, offset))
    }
}
