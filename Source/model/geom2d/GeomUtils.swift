import Foundation

// TODO need to replace this class with model methods
open class GeomUtils {
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

        let rotation = Transform(
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
