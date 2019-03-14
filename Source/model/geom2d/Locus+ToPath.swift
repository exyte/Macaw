import Foundation

extension Locus {

    internal func pointToPath(_ point: Point) -> Path {
        return MoveTo(x: point.x, y: point.y).lineTo(x: point.x, y: point.y).build()
    }

    internal func pointsToPath(_ points: [Double], close: Bool = false) -> Path {
        var pb = PathBuilder(segment: PathSegment(type: .M, data: [points[0], points[1]]))
        if points.count > 2 {
            let parts = stride(from: 2, to: points.count, by: 2).map { Array(points[$0 ..< $0 + 2]) }
            for part in parts {
                pb = pb.lineTo(x: part[0], y: part[1])
            }
        }
        if close {
            pb = pb.close()
        }
        return pb.build()
    }
}
