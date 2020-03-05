import Foundation

// TODO need to replace this class with model methods
open class GeomUtils {

    @available(*, deprecated)
    open class func concat(t1: Transform, t2: Transform) -> Transform {
        return t1.concat(with: t2)
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

        let t1 = move.concat(with: rotation)
        let t2 = t1.concat(with: move.invert()!)
        let result = place.concat(with: t2)

        return result
    }

    open class func centerScale(node: Node, sx: Double, sy: Double) -> Transform {
        let center = GeomUtils.center(node: node)
        return Transform.move(dx: center.x * (1.0 - sx), dy: center.y * (1.0 - sy)).scale(sx: sx, sy: sy)
    }

    open class func center(node: Node) -> Point {
        guard let bounds = node.bounds else {
            return Point()
        }

        return Point(x: bounds.x + bounds.w / 2.0, y: bounds.y + bounds.h / 2.0)
    }
}
