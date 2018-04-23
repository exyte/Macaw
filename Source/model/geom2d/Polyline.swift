import Foundation

open class Polyline: Locus {

    open let points: [Double]

    public init(points: [Double] = []) {
        self.points = points
    }

    override open func bounds() -> Rect {
        guard !points.isEmpty else {
            return Rect.zero()
        }

        var minX = Double(INT16_MAX)
        var minY = Double(INT16_MAX)
        var maxX = Double(INT16_MIN)
        var maxY = Double(INT16_MIN)

        var isX = true
        for point in points {
            if isX {
                if minX > point {
                    minX = point
                }

                if maxX < point {
                    maxX = point
                }
            } else {
                if minY > point {
                    minY = point
                }

                if maxY < point {
                    maxY = point
                }
            }

            isX = !isX
        }

        return Rect(x: minX, y: minY,
                    w: maxX - minX,
                    h: maxY - minY)
    }
}
