import Foundation

open class ColorMatrixEffect: Effect {

    public let matrix: [Double]

    public init(matrix: [Double] = [1, 0, 0, 0, 0,
                                    0, 1, 0, 0, 0,
                                    0, 0, 1, 0, 0,
                                    0, 0, 0, 1, 0], input: Effect? = nil) {
        if matrix.count != 20 {
            fatalError("ColorMatrixEffect: wrong matrix count")
        }
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

    public init(saturate: Double, input: Effect? = nil) {
        let s = max(min(saturate, 1), 0)
        self.matrix = [0.213 + 0.787 * s, 0.715 - 0.715 * s, 0.072 - 0.072 * s, 0, 0,
                       0.213 - 0.213 * s, 0.715 + 0.285 * s, 0.072 - 0.072 * s, 0, 0,
                       0.213 - 0.213 * s, 0.715 - 0.715 * s, 0.072 + 0.928 * s, 0, 0,
                       0, 0, 0, 1, 0]
        super.init(input: input)
    }

    public init(hueRotate: Double, input: Effect? = nil) {
        let c = cos(hueRotate)
        let s = sin(hueRotate)
        let m1 = [0.213, 0.715, 0.072,
                  0.213, 0.715, 0.072,
                  0.213, 0.715, 0.072]
        let m2 = [0.787, -0.715, -0.072,
                  -0.213, 0.285, -0.072,
                  -0.213, -0.715, 0.928]
        let m3 = [-0.213, -0.715, 0.928,
                  0.143, 0.140, -0.283,
                  -0.787, 0.715, 0.072]
        let a = { i in
            return m1[i] + c * m2[i] + s * m3[i]
        }
        self.matrix = [a(0), a(1), a(2), 0, 0,
                       a(3), a(4), a(5), 0, 0,
                       a(6), a(7), a(8), 0, 0,
                       0, 0, 0, 1, 0]
        super.init(input: input)
    }

    static func luminanceToAlpha(input: Effect? = nil) -> ColorMatrixEffect {
        return ColorMatrixEffect(matrix: [1, 0, 0, 0, 0,
                                          0, 1, 0, 0, 0,
                                          0, 0, 1, 0, 0,
                                          0.2125, 0.7154, 0.0721, 0, 0],
                                 input: input)
    }
}
