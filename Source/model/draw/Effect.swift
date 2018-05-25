open class Effect {

    open let input: Effect?

    public init(input: Effect?) {
        self.input = input
    }

    public static func dropShadow(dx: Double = 0, dy: Double = -3, radius: Double = 3, color: Color = .black) -> Effect? {
        let blur = GaussianBlur(radius: radius, input: BlendEffect(input: nil))
        let colorMatrix = ColorMatrixEffect(matrix: [Double(color.r())/255.0, 0, 0, 0, 0,
                                                     0, Double(color.g())/255.0, 0, 0, 0,
                                                     0, 0, Double(color.b())/255.0, 0, 0,
                                                     0, 0, 0, Double(color.a())/255.0, 0],
                                            input: blur)
        return OffsetEffect(dx: dx, dy: dy, input: colorMatrix)
    }
}
