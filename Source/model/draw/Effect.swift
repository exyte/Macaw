open class Effect {

    open let input: Effect?

    public init(input: Effect?) {
        self.input = input
    }

    public static func dropShadow(dx: Double = 0, dy: Double = -3, radius: Double = 3) -> Effect? {
        return AlphaEffect(input: OffsetEffect(dx: dx, dy: dy, input: GaussianBlur(radius: radius, input: nil)))
    }
}
