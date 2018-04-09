import Foundation

#if os(iOS)
import UIKit
#endif

open class LinearGradient: Gradient {

    open let x1: Double
    open let y1: Double
    open let x2: Double
    open let y2: Double

    public init(x1: Double = 0, y1: Double = 0, x2: Double = 0, y2: Double = 0, userSpace: Bool = false, stops: [Stop] = []) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        super.init(
            userSpace: userSpace,
            stops: stops
        )
    }

    public convenience init(degree: Double = 0, from: Color, to: Color) {
        self.init(degree: degree, stops: [Stop(offset: 0, color: from), Stop(offset: 1, color: to)])
    }

    public init(degree: Double = 0, stops: [Stop]) {
        let rad = degree * .pi / 180
        var v = [0, 0, cos(rad), sin(rad)]
        let mmax = 1 / max(abs(v[2]), abs(v[3]))
        v[2] *= mmax
        v[3] *= mmax
        if v[2] < 0 {
            v[0] = -v[2]
            v[2] = 0
        }
        if v[3] < 0 {
            v[1] = -v[3]
            v[3] = 0
        }

        self.x1 = v[0]
        self.y1 = v[1]
        self.x2 = v[2]
        self.y2 = v[3]

        super.init(
            userSpace: false,
            stops: stops
        )
    }
}
