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

    func toCG() -> CGColor {
        let red = CGFloat(Double(r()) / 255.0)
        let green = CGFloat(Double(g()) / 255.0)
        let blue = CGFloat(Double(b()) / 255.0)
        let alpha = CGFloat(Double(a()) / 255.0)
        return MColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
    }

}

public extension Transform {

    func toCG() -> CGAffineTransform {
        return CGAffineTransform(a: CGFloat(m11), b: CGFloat(m12), c: CGFloat(m21),
                                 d: CGFloat(m22), tx: CGFloat(dx), ty: CGFloat(dy))
    }

}

public extension LineJoin {

    func toCG() -> CGLineJoin {
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

    func toCG() -> CGLineCap {
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

    func toCG() -> CGRect {
        return CGRect(x: self.x, y: self.y, width: self.w, height: self.h)
    }

    func applying(_ t: Transform) -> Rect {
        return toCG().applying(t.toCG()).toMacaw()
    }

}

public extension CGRect {

    func toMacaw() -> Rect {
        return Rect(x: Double(origin.x),
                    y: Double(origin.y),
                    w: Double(size.width),
                    h: Double(size.height))
    }

}

public extension Size {

    func toCG() -> CGSize {
        return CGSize(width: self.w, height: self.h)
    }

}

public extension CGSize {

    func toMacaw() -> Size {
        return Size(w: Double(width),
                    h: Double(height))
    }

}

public extension Point {

    func toCG() -> CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }

}

public extension CGPoint {

    func toMacaw() -> Point {
        return Point(x: Double(x), y: Double(y))
    }

}

public extension Locus {

    func toCGPath() -> CGPath {
        return RenderUtils.toCGPath(self)
    }

}

public extension CGAffineTransform {

    func toMacaw() -> Transform {
        return Transform(m11: Double(a), m12: Double(b), m21: Double(c), m22: Double(d), dx: Double(tx), dy: Double(ty))
    }
}

public extension Node {

    func toNativeImage(size: Size, layout: ContentLayout = .of(), scale: CGFloat = 0.0) throws -> MImage {
        let renderer = RenderUtils.createNodeRenderer(self, view: nil)
        let rect = size.rect()

        MGraphicsBeginImageContextWithOptions(size.toCG(), false, scale)
        let ctx = MGraphicsGetCurrentContext()!
        ctx.clear(rect.toCG())

        let transform = LayoutHelper.calcTransform(self, layout, size)
        ctx.concatenate(transform.toCG())
        renderer.render(in: ctx, force: false, opacity: self.opacity)
        
        defer {
            MGraphicsEndImageContext()
            renderer.dispose()
        }

        guard let img = MGraphicsGetImageFromCurrentImageContext() else {
            throw CommonError.invalidImageContext
        }

        return img
    }

}

extension MBezierPath {

    public func toMacaw() -> Path {
        let fillRule: FillRule = self.mUsesEvenOddFillRule ? .evenodd : .nonzero
        return self.cgPath.toMacaw(fillRule: fillRule)
    }

}

extension CGPath {

    public func toMacaw(fillRule: FillRule = .nonzero) -> Path {

        func createPathSegment(type: PathSegmentType, points: UnsafeMutablePointer<CGPoint>, count: Int) -> PathSegment {

            var data = [Double]()
            for index in 0..<count {
                let point = points[index]
                data.append(contentsOf: [Double(point.x), Double(point.y)])
            }
            return PathSegment(type: type, data: data)
        }

        var segments = [PathSegment]()
        self.forEach { (element: CGPathElement) in

            let segment: PathSegment
            switch element.type {
            case .moveToPoint:
                segment = createPathSegment(type: .M, points: element.points, count: 1)
            case .addLineToPoint:
                segment = createPathSegment(type: .L, points: element.points, count: 1)
            case .addQuadCurveToPoint:
                segment = createPathSegment(type: .Q, points: element.points, count: 2)
            case .addCurveToPoint:
                segment = createPathSegment(type: .C, points: element.points, count: 3)
            case .closeSubpath:
                segment = PathSegment(type: .z)
            @unknown default:
                fatalError("Unknown element type: \(element.type)")
            }
            segments.append(segment)
        }

        return Path(segments: segments, fillRule: .nonzero)
    }

    private func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        func callback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: callback)
    }
}
