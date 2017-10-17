import Foundation

open class GeomUtils {
    
    open class func rectToPath(_ rect: Rect) -> Path {
        return MoveTo(x: rect.x, y: rect.y).lineTo(x: rect.x + rect.w, y: rect.y).lineTo(x: rect.x + rect.w, y: rect.y + rect.h).lineTo(x: rect.x, y: rect.y + rect.h).close().build()
    }
    
    open class func circleToPath(_ circle: Circle) -> Path {
        let arc = Arc(ellipse: Ellipse(cx: circle.cx, cy: circle.cy, rx: circle.r, ry: circle.r), shift: 0.0, extent: 2*Double.pi - 0.0000001)
        return arcToPath(arc)
    }
    
    open class func arcToPath(_ arc: Arc) -> Path {
        let rx = arc.ellipse.rx
        let ry = arc.ellipse.ry
        let cx = arc.ellipse.cx
        let cy = arc.ellipse.cy

        var delta = arc.extent
        if (arc.shift == 0.0 && abs(arc.extent - Double.pi * 2.0) < 0.00001) {
            delta = Double.pi * 2.0 - 0.001
        }
        let theta1 = arc.shift

        let theta2 = theta1 + delta
        
        let x1 = cx + rx * cos(theta1)
        let y1 = cy + ry * sin(theta1)
        
        let x2 = cx + rx * cos(theta2)
        let y2 = cy + ry * sin(theta2)
        
        let largeArcFlag = abs(delta) > .pi ? true : false
        let sweepFlag = delta > 0.0 ? true : false
        
        return PathBuilder(segment: PathSegment(type: .M, data: [x1, y1])).A(rx, ry, 0.0, largeArcFlag, sweepFlag, x2, y2).build()
    }
    
    open class func pointToPath(_ point: Point) -> Path {
        return MoveTo(x: point.x, y: point.y).lineTo(x: point.x, y: point.y).build()
    }
    
    fileprivate class func pointsToPath(_ points: [Double], close: Bool = false) -> Path {
        var pb = PathBuilder(segment: PathSegment(type: .M, data: [points[0], points[1]]))
        if (points.count > 2) {
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
    
    open class func toPath(_ locus: Locus) -> Path {
        if let rect = locus as? Rect {
            return MoveTo(x: rect.x, y: rect.y).H(rect.h + rect.x).V(rect.w + rect.y).H(rect.x).L(rect.x, rect.y).build()
        } else if let arc = locus as? Arc {
            return arcToPath(arc)
        } else if let point = locus as? Point {
            return MoveTo(x: point.x, y: point.y).lineTo(x: point.x, y: point.y).build()
        }  else if let line = locus as? Line {
            return MoveTo(x: line.x1, y: line.y1).lineTo(x: line.x2, y: line.y2).build()
        } else if let polygon = locus as? Polygon {
            return pointsToPath(polygon.points, close: true)
        } else if let polyline = locus as? Polyline {
            return pointsToPath(polyline.points)
        }
        fatalError("Unsupported locus: \(locus)")
    }
    
    open class func concat(t1: Transform, t2: Transform) -> Transform {
        let nm11 = t2.m11 * t1.m11 + t2.m12 * t1.m21
        let nm21 = t2.m21 * t1.m11 + t2.m22 * t1.m21
        let ndx = t2.dx * t1.m11 + t2.dy * t1.m21 + t1.dx
        let nm12 = t2.m11 * t1.m12 + t2.m12 * t1.m22
        let nm22 = t2.m21 * t1.m12 + t2.m22 * t1.m22
        let ndy = t2.dx * t1.m12 + t2.dy * t1.m22 + t1.dy
        return Transform(m11: nm11, m12: nm12, m21: nm21, m22: nm22, dx: ndx, dy: ndy)
    }
    
    open class func centerRotation(node: Node, place: Transform, angle: Double) -> Transform {
        let center = GeomUtils.center(node: node)
        return GeomUtils.anchorRotation(node: node, place: place, anchor: center, angle: angle)
    }
    
    open class func anchorRotation(node: Node, place: Transform, anchor: Point, angle: Double) -> Transform {
        let move = Transform.move(dx: anchor.x, dy: anchor.y)
        
        let asin = sin(angle); let acos = cos(angle)
        
        let rotation =  Transform(
            m11: acos, m12: -asin,
            m21: asin, m22: acos,
            dx: 0.0, dy: 0.0
        )
        
        let t1 = GeomUtils.concat(t1: move, t2: rotation)
        let t2 = GeomUtils.concat(t1: t1, t2: move.invert()!)
        let result = GeomUtils.concat(t1: place, t2: t2)
        
        return result
    }
    
    open class func centerScale(node: Node, sx: Double, sy: Double) -> Transform {
        let center = GeomUtils.center(node: node)
        return Transform.move(dx: center.x * (1.0 - sx), dy: center.y * (1.0 - sy)).scale(sx: sx, sy: sy)
    }
    
    open class func center(node: Node) -> Point {
        guard let bounds = node.bounds() else {
            return Point()
        }
        
        return Point(x: bounds.x + bounds.w / 2.0, y: bounds.y + bounds.h / 2.0)
    }
}
