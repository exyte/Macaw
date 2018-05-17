open class Effect {

    open let input: Effect?

    public init(input: Effect?) {
        self.input = input
    }

    public static func dropShadow(dx: Double = 5, dy: Double = 5, radius: Double = 5) -> Effect? {
        return AlphaEffect(input: OffsetEffect(dx: dx, dy: dy, input: GaussianBlur(radius: radius, input: nil)))
    }
}
