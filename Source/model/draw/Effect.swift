open class Effect {

    open let input: Effect?

    public init(input: Effect?) {
        self.input = input
    }

    public static func dropShadow(dx: Double = 0, dy: Double = -3, radius: Double = 3, color: Color = .black) -> Effect? {
        let blur = GaussianBlur(radius: radius, input: BlendEffect(input: nil))
        return OffsetEffect(dx: dx, dy: dy, input: ColorMatrixEffect(color: color, input: blur))
    }
}
