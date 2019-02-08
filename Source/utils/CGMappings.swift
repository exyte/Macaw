//
//  CGMappings
//  Created by Yuri Strot on 5/14/18.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

public extension Color {

    public func toCG() -> CGColor {
        let red = CGFloat(Double(r()) / 255.0)
        let green = CGFloat(Double(g()) / 255.0)
        let blue = CGFloat(Double(b()) / 255.0)
        let alpha = CGFloat(Double(a()) / 255.0)
        return MColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
    }

}

public extension Transform {

    public func toCG() -> CGAffineTransform {
        return CGAffineTransform(a: CGFloat(m11), b: CGFloat(m12), c: CGFloat(m21),
                                 d: CGFloat(m22), tx: CGFloat(dx), ty: CGFloat(dy))
    }

}

public extension LineJoin {

    public func toCG() -> CGLineJoin {
        switch self {
        case .round:
            return .round
        case .bevel:
            return CGLineJoin.bevel
        default:
            return CGLineJoin.miter
        }
    }

}

public extension LineCap {

    public func toCG() -> CGLineCap {
        switch self {
        case .round:
            return CGLineCap.round
        case .square:
            return CGLineCap.square
        default:
            return CGLineCap.butt
        }
    }

}

public extension Rect {

    public func toCG() -> CGRect {
        return CGRect(x: self.x, y: self.y, width: self.w, height: self.h)
    }

    func applying(_ t: Transform) -> Rect {
        return toCG().applying(t.toCG()).toMacaw()
    }

}

public extension CGRect {

    public func toMacaw() -> Rect {
        return Rect(x: Double(origin.x),
                    y: Double(origin.y),
                    w: Double(size.width),
                    h: Double(size.height))
    }

}

public extension Size {

    public func toCG() -> CGSize {
        return CGSize(width: self.w, height: self.h)
    }

}

public extension CGSize {

    public func toMacaw() -> Size {
        return Size(w: Double(width),
                    h: Double(height))
    }

}

public extension Point {

    public func toCG() -> CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }

}

public extension CGPoint {

    public func toMacaw() -> Point {
        return Point(x: Double(x), y: Double(y))
    }

}

public extension Locus {

    public func toCGPath() -> CGPath {
        return RenderUtils.toCGPath(self)
    }

}

public extension CGAffineTransform {

    public func toMacaw() -> Transform {
        return Transform(m11: Double(a), m12: Double(b), m21: Double(c), m22: Double(d), dx: Double(tx), dy: Double(ty))
    }
}

public extension Node {

    public func toNativeImage(size: Size, layout: ContentLayout = .of()) -> MImage {
        let renderer = RenderUtils.createNodeRenderer(self, view: nil, animationCache: nil)
        let rect = size.rect()

        MGraphicsBeginImageContextWithOptions(size.toCG(), false, 1)
        let ctx = MGraphicsGetCurrentContext()!
        ctx.clear(rect.toCG())

        let transform = LayoutHelper.calcTransform(self, layout, size)
        ctx.concatenate(transform.toCG())
        renderer.render(in: ctx, force: false, opacity: self.opacity)

        let img = MGraphicsGetImageFromCurrentImageContext()
        MGraphicsEndImageContext()
        return img!
    }

}
