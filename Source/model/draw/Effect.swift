open class Effect {

    public let input: Effect?

    public init(input: Effect?) {
        self.input = input
    }

    public static func dropShadow(dx: Double = 0, dy: Double = -3, r: Double = 3, color: Color = .black) -> Effect? {
        OffsetEffect(dx: dx, dy: dy).setColor(to: color).blur(r: r).blend()
    }

    public func offset(dx: Double, dy: Double) -> Effect {
        OffsetEffect(dx: dx, dy: dy, input: self)
    }

    public func mapColor(with matrix: ColorMatrix) -> Effect {
        ColorMatrixEffect(matrix: matrix, input: self)
    }

    public func setColor(to color: Color) -> Effect {
        ColorMatrixEffect(matrix: ColorMatrix(color: color), input: self)
    }

    public func blur(r: Double) -> Effect {
        GaussianBlur(r: r, input: self)
    }

    public func blend() -> Effect {
        BlendEffect(input: self)
    }
}
