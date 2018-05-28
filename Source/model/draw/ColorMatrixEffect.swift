open class ColorMatrixEffect: Effect {

    public let matrix: [Double]

    public init(matrix: [Double] = [], input: Effect? = nil) {
        self.matrix = matrix
        super.init(input: input)
    }

    public init(color: Color, input: Effect? = nil) {
        self.matrix = [Double(color.r()) / 255.0, 0, 0, 0, 0,
                       0, Double(color.g()) / 255.0, 0, 0, 0,
                       0, 0, Double(color.b()) / 255.0, 0, 0,
                       0, 0, 0, Double(color.a()) / 255.0, 0]
        super.init(input: input)
    }

}
