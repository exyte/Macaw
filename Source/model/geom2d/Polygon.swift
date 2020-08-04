import Foundation

open class Polygon: Locus {

    public let points: [Double]

    public init(_ points: [Double]) {
        self.points = points
    }

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

    override open func toPath() -> Path {
        var pb = PathBuilder(segment: PathSegment(type: .M, data: [points[0], points[1]]))
        if points.count > 2 {
            let parts = stride(from: 2, to: points.count, by: 2).map { Array(points[$0 ..< $0 + 2]) }
            for part in parts {
                pb = pb.lineTo(x: part[0], y: part[1])
            }
        }
        return pb.close().build()
    }

    override func equals<T>(other: T) -> Bool where T: Locus {
        guard let other = other as? Polygon else {
            return false
        }
        return points == other.points
    }
}
