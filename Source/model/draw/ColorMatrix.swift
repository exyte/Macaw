//
//  ColorMatrix.swift
//  Macaw
//
//  Created by Yuri Strot on 6/20/18.
//  Copyright © 2018 Exyte. All rights reserved.
//
import Foundation

open class ColorMatrix {

    public static let identity = ColorMatrix(
        values: [1, 0, 0, 0, 0,
                 0, 1, 0, 0, 0,
                 0, 0, 1, 0, 0,
                 0, 0, 0, 1, 0])

    public static let luminanceToAlpha = ColorMatrix(
        values: [1, 0, 0, 0, 0,
                 0, 1, 0, 0, 0,
                 0, 0, 1, 0, 0,
                 0.2125, 0.7154, 0.0721, 0, 0])

    public let values: [Double]

    public init(values: [Double]) {
        if values.count != 20 {
            fatalError("ColorMatrix: wrong matrix count")
        }
        self.values = values
    }

    public convenience init(color: Color) {
        self.init(values: [0, 0, 0, 0, Double(color.r()) / 255.0,
                           0, 0, 0, 0, Double(color.g()) / 255.0,
                           0, 0, 0, 0, Double(color.b()) / 255.0,
                           0, 0, 0, Double(color.a()) / 255.0, 0])
    }

    public convenience init(saturate: Double) {
        let s = max(min(saturate, 1), 0)
        self.init(values: [0.213 + 0.787 * s, 0.715 - 0.715 * s, 0.072 - 0.072 * s, 0, 0,
                           0.213 - 0.213 * s, 0.715 + 0.285 * s, 0.072 - 0.072 * s, 0, 0,
                           0.213 - 0.213 * s, 0.715 - 0.715 * s, 0.072 + 0.928 * s, 0, 0,
                           0, 0, 0, 1, 0])
    }

    public convenience init(hueRotate: Double) {
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
        let a = { (i: Int) -> Double in
            m1[i] + c * m2[i] + s * m3[i]
        }
        self.init(values: [a(0), a(1), a(2), 0, 0,
                           a(3), a(4), a(5), 0, 0,
                           a(6), a(7), a(8), 0, 0,
                           0, 0, 0, 1, 0])
    }

}
