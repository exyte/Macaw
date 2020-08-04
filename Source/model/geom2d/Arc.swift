import Foundation

open class Arc: Locus {

    public let ellipse: Ellipse
    public let shift: Double
    public let extent: Double

    public init(ellipse: Ellipse, shift: Double = 0, extent: Double = 0) {
        self.ellipse = ellipse
        self.shift = shift
        self.extent = extent
    }

    override open func bounds() -> Rect {
        return Rect(
            x: ellipse.cx - ellipse.rx,
            y: ellipse.cy - ellipse.ry,
            w: ellipse.rx * 2.0,
            h: ellipse.ry * 2.0)
    }

    override open func toPath() -> Path {
        let rx = ellipse.rx
        let ry = ellipse.ry
        let cx = ellipse.cx
        let cy = ellipse.cy

        var delta = extent
        if shift == 0.0 && abs(extent - .pi * 2.0) < 0.00001 {
            delta = .pi * 2.0 - 0.001
        }
        let theta1 = shift

        let theta2 = theta1 + delta

        let x1 = cx + rx * cos(theta1)
        let y1 = cy + ry * sin(theta1)

        let x2 = cx + rx * cos(theta2)
        let y2 = cy + ry * sin(theta2)

        let largeArcFlag = abs(delta) > .pi ? true : false
        let sweepFlag = delta > 0.0 ? true : false

        return PathBuilder(segment: PathSegment(type: .M, data: [x1, y1])).A(rx, ry, 0.0, largeArcFlag, sweepFlag, x2, y2).build()
    }

    override func equals<T>(other: T) -> Bool where T: Locus {
        guard let other = other as? Arc else {
            return false
        }
        return ellipse == other.ellipse
            && shift == other.shift
            && extent == other.extent
    }
}
