import Foundation

open class ColorMatrixEffect: Effect {

    public let matrix: ColorMatrix

    public init(matrix: ColorMatrix, input: Effect? = nil) {
        self.matrix = matrix
        super.init(input: input)
    }

}
