open class ColorMatrixEffect: Effect {
    
    public let matrix: [Double]?
    
    public init(matrix: [Double] = [], input: Effect? = nil) {
        self.matrix = matrix
        super.init(input: input)
    }
}
