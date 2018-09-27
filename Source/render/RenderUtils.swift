import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class RenderUtils {

    class func mapDash(_ dashes: [Double]) -> UnsafeMutablePointer<CGFloat> {
        let p = UnsafeMutablePointer<CGFloat>.allocate(capacity: dashes.count * MemoryLayout<CGFloat>.size)
        for (index, item) in dashes.enumerated() {
            p[index] = CGFloat(item)
        }
        return p
    }

    class func createNodeRenderer(
        _ node: Node,
        view: MView?,
        animationCache: AnimationCache?,
        interval: RenderingInterval? = .none
        ) -> NodeRenderer {
        if let group = node as? Group {
            return GroupRenderer(group: group, view: view, animationCache: animationCache, interval: interval)
        } else if let shape = node as? Shape {
            return ShapeRenderer(shape: shape, view: view, animationCache: animationCache)
        } else if let text = node as? Text {
            return TextRenderer(text: text, view: view, animationCache: animationCache)
        } else if let image = node as? Image {
            return ImageRenderer(image: image, view: view, animationCache: animationCache)
        }
        fatalError("Unsupported node: \(node)")
    }

    static let availableFonts = MFont.mFamilyNames.map { $0.lowercased() }

    class func loadFont(name: String, size: Int, weight: String?) -> MFont? {

        var fontName = ""
        let fontPriorities = name.split(separator: ",").map { String($0).trimmingCharacters(in: CharacterSet(charactersIn: " '")) }

        for font in fontPriorities {
            let lowercasedFont = font.lowercased()

            if availableFonts.contains(lowercasedFont) {
                fontName = font
            }

            if lowercasedFont == "serif" {
                fontName = "Georgia"
            }
            if lowercasedFont == "sans-serif" {
                fontName = "Arial"
            }
            if lowercasedFont == "monospace" {
                fontName = "Courier"
            }
        }
        if fontName.isEmpty {
            return .none
        }

        var fontDesc = MFontDescriptor(name: fontName, size: CGFloat(size))
        if weight == "bold" || weight == "bolder" {
            #if os(iOS)
            fontDesc = fontDesc.withSymbolicTraits(.traitBold)!
            #elseif os(OSX)
            fontDesc = fontDesc.withSymbolicTraits(.bold)
            #endif

        }
        return MFont(descriptor: fontDesc, size: CGFloat(size))
    }

    class func applyOpacity(_ color: Color, opacity: Double) -> Color {
        return Color.rgba(r: color.r(), g: color.g(), b: color.b(), a: Double(color.a()) / 255.0 * opacity)
    }

    class func toCGPath(_ locus: Locus) -> CGPath {
        if let arc = locus as? Arc {
            if arc.ellipse.rx != arc.ellipse.ry {
                // http://stackoverflow.com/questions/11365775/how-to-draw-an-elliptical-arc-with-coregraphics
                // input parameters
                let ellipse = arc.ellipse
                let startAngle = CGFloat(arc.shift)
                let endAngle = startAngle + CGFloat(arc.extent)
                let r = CGFloat(ellipse.rx)
                let scale = CGFloat(ellipse.ry / ellipse.rx)
                let path = CGMutablePath()
                var t = CGAffineTransform(translationX: CGFloat(ellipse.cx), y: CGFloat(ellipse.cy))
                t = CGAffineTransform(scaleX: 1.0, y: scale).concatenating(t)
                path.addArc(center: CGPoint.zero, radius: r, startAngle: startAngle, endAngle: endAngle, clockwise: false, transform: t)
                return path
            }
        }
        return toBezierPath(locus).cgPath
    }

    class func toBezierPath(_ locus: Locus) -> MBezierPath {
        if let round = locus as? RoundRect {
            let corners = CGSize(width: CGFloat(round.rx), height: CGFloat(round.ry))
            return MBezierPath(roundedRect: round.rect.toCG(), byRoundingCorners:
                MRectCorner.allCorners, cornerRadii: corners)
        } else if let arc = locus as? Arc {
            if arc.ellipse.rx == arc.ellipse.ry {
                return arcToPath(arc)
            }
        } else if let point = locus as? Point {
            let path = MBezierPath()
            path.move(to: CGPoint(x: CGFloat(point.x), y: CGFloat(point.y)))
            path.addLine(to: CGPoint(x: CGFloat(point.x), y: CGFloat(point.y)))
            return path
        } else if let line = locus as? Line {
            let path = MBezierPath()
            path.move(to: CGPoint(x: CGFloat(line.x1), y: CGFloat(line.y1)))
            path.addLine(to: CGPoint(x: CGFloat(line.x2), y: CGFloat(line.y2)))
            return path
        } else if let polygon = locus as? Polygon {
            let path = pointsToPath(polygon.points)
            path.close()
            return path
        } else if let polygon = locus as? Polyline {
            return pointsToPath(polygon.points)
        } else if let rect = locus as? Rect {
            return MBezierPath(rect: rect.toCG())
        } else if let circle = locus as? Circle {
            return MBezierPath(ovalIn: circle.bounds().toCG())
        } else if let path = locus as? Path {
            return toBezierPath(path)
        } else if let transformedLocus = locus as? TransformedLocus {
            let path = toBezierPath(transformedLocus.locus)
            path.apply(transformedLocus.transform.toCG())
            return path
        } else if let ellipse = locus as? Ellipse {
            return MBezierPath(ovalIn: ellipse.bounds().toCG())
        }

        fatalError("Unsupported locus: \(locus)")
    }

    fileprivate class func arcToPath(_ arc: Arc) -> MBezierPath {
        let shift = CGFloat(arc.shift)
        let end = shift + CGFloat(arc.extent)
        let ellipse = arc.ellipse
        let center = CGPoint(x: CGFloat(ellipse.cx), y: CGFloat(ellipse.cy))
        return MBezierPath(arcCenter: center, radius: CGFloat(ellipse.rx), startAngle: shift, endAngle: end, clockwise: true)
    }

    fileprivate class func pointsToPath(_ points: [Double]) -> MBezierPath {
        let count = points.count / 2 * 2 // points count divisible by 2
        let parts = stride(from: 0, to: count, by: 2).map { Array(points[$0 ..< $0 + 2]) }
        let path = MBezierPath()
        var first = true
        for part in parts {
            let point = CGPoint(x: CGFloat(part[0]), y: CGFloat(part[1]))
            if first {
                path.move(to: point)
                first = false
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    fileprivate class func toBezierPath(_ path: Path) -> MBezierPath {
        let bezierPath = MBezierPath()

        var currentPoint: CGPoint?
        var cubicPoint: CGPoint?
        var quadrPoint: CGPoint?
        var initialPoint: CGPoint?

        func M(_ x: Double, y: Double) {
            let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
            bezierPath.move(to: point)
            setInitPoint(point)
        }

        func m(_ x: Double, y: Double) {
            if let cur = currentPoint {
                let next = CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(y) + cur.y)
                bezierPath.move(to: next)
                setInitPoint(next)
            } else {
                M(x, y: y)
            }
        }

        func L(_ x: Double, y: Double) {
            lineTo(CGPoint(x: CGFloat(x), y: CGFloat(y)))
        }

        func l(_ x: Double, y: Double) {
            if let cur = currentPoint {
                lineTo(CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(y) + cur.y))
            } else {
                L(x, y: y)
            }
        }

        func H(_ x: Double) {
            if let cur = currentPoint {
                lineTo(CGPoint(x: CGFloat(x), y: CGFloat(cur.y)))
            }
        }

        func h(_ x: Double) {
            if let cur = currentPoint {
                lineTo(CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(cur.y)))
            }
        }

        func V(_ y: Double) {
            if let cur = currentPoint {
                lineTo(CGPoint(x: CGFloat(cur.x), y: CGFloat(y)))
            }
        }

        func v(_ y: Double) {
            if let cur = currentPoint {
                lineTo(CGPoint(x: CGFloat(cur.x), y: CGFloat(y) + cur.y))
            }
        }

        func lineTo(_ p: CGPoint) {
            bezierPath.addLine(to: p)
            setPoint(p)
        }

        func c(_ x1: Double, y1: Double, x2: Double, y2: Double, x: Double, y: Double) {
            if let cur = currentPoint {
                let endPoint = CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(y) + cur.y)
                let controlPoint1 = CGPoint(x: CGFloat(x1) + cur.x, y: CGFloat(y1) + cur.y)
                let controlPoint2 = CGPoint(x: CGFloat(x2) + cur.x, y: CGFloat(y2) + cur.y)
                bezierPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                setCubicPoint(endPoint, cubic: controlPoint2)
            }
        }

        func C(_ x1: Double, y1: Double, x2: Double, y2: Double, x: Double, y: Double) {
            let endPoint = CGPoint(x: CGFloat(x), y: CGFloat(y))
            let controlPoint1 = CGPoint(x: CGFloat(x1), y: CGFloat(y1))
            let controlPoint2 = CGPoint(x: CGFloat(x2), y: CGFloat(y2))
            bezierPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            setCubicPoint(endPoint, cubic: controlPoint2)
        }

        func s(_ x2: Double, y2: Double, x: Double, y: Double) {
            if let cur = currentPoint {
                let nextCubic = CGPoint(x: CGFloat(x2) + cur.x, y: CGFloat(y2) + cur.y)
                let next = CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(y) + cur.y)

                var xy1: CGPoint?
                if let curCubicVal = cubicPoint {
                    xy1 = CGPoint(x: CGFloat(2 * cur.x) - curCubicVal.x, y: CGFloat(2 * cur.y) - curCubicVal.y)
                } else {
                    xy1 = cur
                }
                bezierPath.addCurve(to: next, controlPoint1: xy1!, controlPoint2: nextCubic)
                setCubicPoint(next, cubic: nextCubic)
            }
        }

        func S(_ x2: Double, y2: Double, x: Double, y: Double) {
            if let cur = currentPoint {
                let nextCubic = CGPoint(x: CGFloat(x2), y: CGFloat(y2))
                let next = CGPoint(x: CGFloat(x), y: CGFloat(y))
                var xy1: CGPoint?
                if let curCubicVal = cubicPoint {
                    xy1 = CGPoint(x: CGFloat(2 * cur.x) - curCubicVal.x, y: CGFloat(2 * cur.y) - curCubicVal.y)
                } else {
                    xy1 = cur
                }
                bezierPath.addCurve(to: next, controlPoint1: xy1!, controlPoint2: nextCubic)
                setCubicPoint(next, cubic: nextCubic)
            }
        }

        func q(_ x1: Double, y1: Double, x: Double, y: Double) {
            if let cur = currentPoint {
                let dx = Double(cur.x)
                let dy = Double(cur.y)
                Q(x1 + dx, y1: y1 + dy, x: x + dx, y: y + dy)
            }
        }

        func Q(_ x1: Double, y1: Double, x: Double, y: Double) {
            let endPoint = CGPoint(x: x, y: y)
            let controlPoint = CGPoint(x: x1, y: y1)
            bezierPath.addQuadCurve(to: endPoint, controlPoint: controlPoint)
            setQuadrPoint(endPoint, quadr: controlPoint)
        }

        func t(_ x: Double, y: Double) {
            if let cur = currentPoint {
                let next = CGPoint(x: CGFloat(x) + cur.x, y: CGFloat(y) + cur.y)
                var quadr: CGPoint?
                if let curQuadr = quadrPoint {
                    quadr = CGPoint(x: 2 * cur.x - curQuadr.x, y: 2 * cur.y - curQuadr.y)
                } else {
                    quadr = cur
                }
                bezierPath.addQuadCurve(to: next, controlPoint: quadr!)
                setQuadrPoint(next, quadr: quadr!)
            }
        }

        func T(_ x: Double, y: Double) {
            if let cur = currentPoint {
                let next = CGPoint(x: CGFloat(x), y: CGFloat(y))
                var quadr: CGPoint?
                if let curQuadr = quadrPoint {
                    quadr = CGPoint(x: 2 * cur.x - curQuadr.x, y: 2 * cur.y - curQuadr.y)
                } else {
                    quadr = cur
                }
                bezierPath.addQuadCurve(to: next, controlPoint: quadr!)
                setQuadrPoint(next, quadr: quadr!)
            }
        }

        func a(_ rx: Double, ry: Double, angle: Double, largeArc: Bool, sweep: Bool, x: Double, y: Double) {
            if let cur = currentPoint {
                A(rx, ry: ry, angle: angle, largeArc: largeArc, sweep: sweep, x: x + Double(cur.x), y: y + Double(cur.y))
            }
        }

        func A(_ _rx: Double, ry _ry: Double, angle _angle: Double, largeArc: Bool, sweep: Bool, x: Double, y: Double) {
            let angle = _angle * .pi / 180

            if let cur = currentPoint {
                let x1 = Double(cur.x)
                let y1 = Double(cur.y)

                // find arc center coordinates and points angles as per
                // http://www.w3.org/TR/SVG/implnote.html#ArcConversionEndpointToCenter
                if _rx == 0 || _ry == 0 {
                    L(x, y: y)
                } else {
                    var rx = abs(_rx)
                    var ry = abs(_ry)
                    let x1_ = cos(angle) * (x1 - x) / 2 + sin(angle) * (y1 - y) / 2
                    let y1_ = -1 * sin(angle) * (x1 - x) / 2 + cos(angle) * (y1 - y) / 2

                    let rCheck = (x1_ * x1_) / (rx * rx) + (y1_ * y1_) / (ry * ry)
                    if rCheck > 1 {
                        rx = sqrt(rCheck) * rx
                        ry = sqrt(rCheck) * ry
                    }

                    // make sure the value under the root is positive
                    let underroot = (rx * rx * ry * ry - rx * rx * y1_ * y1_ - ry * ry * x1_ * x1_)
                        / (rx * rx * y1_ * y1_ + ry * ry * x1_ * x1_)
                    var bigRoot = (underroot > 0) ? sqrt(underroot) : 0
                    bigRoot = (bigRoot <= 1e-2) ? 0 : bigRoot
                    let coef: Double = (sweep != largeArc) ? 1 : -1
                    let cx_ = coef * bigRoot * rx * y1_ / ry
                    let cy_ = -1 * coef * bigRoot * ry * x1_ / rx
                    let cx = cos(angle) * cx_ - sin(angle) * cy_ + (x1 + x) / 2
                    let cy = sin(angle) * cx_ + cos(angle) * cy_ + (y1 + y) / 2

                    let t1 = calcAngle(ux: 1, uy: 0, vx: (x1_ - cx_) / rx, vy: (y1_ - cy_) / ry)
                    var delta = calcAngle(ux: (x1_ - cx_) / rx, uy: (y1_ - cy_) / ry, vx: (-x1_ - cx_) / rx, vy: (-y1_ - cy_) / ry)
                    let pi2 = Double.pi * 2
                    if delta > 0 {
                        delta = delta.truncatingRemainder(dividingBy: pi2)
                        if !sweep {
                            delta -= pi2
                        }
                    } else if delta < 0 {
                        delta = -1 * ((-1 * delta).truncatingRemainder(dividingBy: pi2))
                        if sweep {
                            delta += pi2
                        }
                    }
                    E(cx - rx, y: cy - ry, w: 2 * rx, h: 2 * ry, startAngle: t1, arcAngle: delta, rotation: angle)
                    setPoint(CGPoint(x: CGFloat(x), y: CGFloat(y)))
                }
            }
        }

        func E(_ x: Double, y: Double, w: Double, h: Double, startAngle: Double, arcAngle: Double, rotation: Double = 0) {
            let extent = CGFloat(startAngle)
            let end = extent + CGFloat(arcAngle)
            let cx = CGFloat(x + w / 2)
            let cy = CGFloat(y + h / 2)
            if w == h && rotation == 0 {
                bezierPath.addArc(withCenter: CGPoint(x: cx, y: cy), radius: CGFloat(w / 2), startAngle: extent, endAngle: end, clockwise: arcAngle >= 0)
            } else {
                let maxSize = CGFloat(max(w, h))
                let path = MBezierPath(arcCenter: CGPoint.zero, radius: maxSize / 2, startAngle: extent, endAngle: end, clockwise: arcAngle >= 0)

                #if os(iOS)
                var transform = CGAffineTransform(translationX: cx, y: cy)
                transform = transform.rotated(by: CGFloat(rotation))
                path.apply(transform.scaledBy(x: CGFloat(w) / maxSize, y: CGFloat(h) / maxSize))
                #elseif os(OSX)
                var transform = AffineTransform(translationByX: cx, byY: cy)
                transform.rotate(byDegrees: CGFloat(rotation))
                path.transform(using: transform)
                #endif

                bezierPath.append(path)
            }
        }

        func e(_ x: Double, y: Double, w: Double, h: Double, startAngle: Double, arcAngle: Double) {
            // TODO: only circle now
            if let cur = currentPoint {
                E(x + Double(cur.x), y: y + Double(cur.y), w: w, h: h, startAngle: startAngle, arcAngle: arcAngle)
            }
        }

        func Z() {
            if let initPoint = initialPoint {
                lineTo(initPoint)
            }
            bezierPath.close()
        }

        func setQuadrPoint(_ p: CGPoint, quadr: CGPoint) {
            currentPoint = p
            quadrPoint = quadr
            cubicPoint = nil
        }

        func setCubicPoint(_ p: CGPoint, cubic: CGPoint) {
            currentPoint = p
            cubicPoint = cubic
            quadrPoint = nil
        }

        func setInitPoint(_ p: CGPoint) {
            setPoint(p)
            initialPoint = p
        }

        func setPoint(_ p: CGPoint) {
            currentPoint = p
            cubicPoint = nil
            quadrPoint = nil
        }

        // TODO: think about this
        for part in path.segments {
            var data = part.data
            switch part.type {
            case .M:
                M(data[0], y: data[1])
                data.removeSubrange(Range(uncheckedBounds: (lower: 0, upper: 2)))
                while data.count >= 2 {
                    L(data[0], y: data[1])
                    data.removeSubrange((0 ..< 2))
                }
            case .m:
                m(data[0], y: data[1])
                data.removeSubrange((0 ..< 2))
                while data.count >= 2 {
                    l(data[0], y: data[1])
                    data.removeSubrange((0 ..< 2))
                }
            case .L:
                while data.count >= 2 {
                    L(data[0], y: data[1])
                    data.removeSubrange((0 ..< 2))
                }
            case .l:
                while data.count >= 2 {
                    l(data[0], y: data[1])
                    data.removeSubrange((0 ..< 2))
                }
            case .H:
                H(data[0])
            case .h:
                h(data[0])
            case .V:
                V(data[0])
            case .v:
                v(data[0])
            case .C:
                while data.count >= 6 {
                    C(data[0], y1: data[1], x2: data[2], y2: data[3], x: data[4], y: data[5])
                    data.removeSubrange((0 ..< 6))
                }
            case .c:
                while data.count >= 6 {
                    c(data[0], y1: data[1], x2: data[2], y2: data[3], x: data[4], y: data[5])
                    data.removeSubrange((0 ..< 6))
                }
            case .S:
                while data.count >= 4 {
                    S(data[0], y2: data[1], x: data[2], y: data[3])
                    data.removeSubrange((0 ..< 4))
                }
            case .s:
                while data.count >= 4 {
                    s(data[0], y2: data[1], x: data[2], y: data[3])
                    data.removeSubrange((0 ..< 4))
                }
            case .Q:
                Q(data[0], y1: data[1], x: data[2], y: data[3])
            case .q:
                q(data[0], y1: data[1], x: data[2], y: data[3])
            case .T:
                T(data[0], y: data[1])
            case .t:
                t(data[0], y: data[1])
            case .A:
                A(data[0], ry: data[1], angle: data[2], largeArc: num2bool(data[3]), sweep: num2bool(data[4]), x: data[5], y: data[6])
            case .a:
                a(data[0], ry: data[1], angle: data[2], largeArc: num2bool(data[3]), sweep: num2bool(data[4]), x: data[5], y: data[6])
            case .E:
                E(data[0], y: data[1], w: data[2], h: data[3], startAngle: data[4], arcAngle: data[5])
            case .e:
                e(data[0], y: data[1], w: data[2], h: data[3], startAngle: data[4], arcAngle: data[5])
            case .z:
                Z()
            }
        }
        return bezierPath
    }

    class func calcAngle(ux: Double, uy: Double, vx: Double, vy: Double) -> Double {
        let sign = copysign(1, ux * vy - uy * vx)
        let value = (ux * vx + uy * vy) / (sqrt(ux * ux + uy * uy) * sqrt(vx * vx + vy * vy))
        if value < -1 {
            return sign * .pi
        } else if value > 1 {
            return 0
        } else {
            return sign * acos(value)
        }
    }

    class func num2bool(_ double: Double) -> Bool {
        return double > 0.5 ? true : false
    }

    internal class func setStrokeAttributes(_ stroke: Stroke, ctx: CGContext?) {
        ctx!.setLineWidth(CGFloat(stroke.width))
        ctx!.setLineJoin(stroke.join.toCG())
        ctx!.setLineCap(stroke.cap.toCG())
        ctx!.setMiterLimit(CGFloat(stroke.miterLimit))
        if !stroke.dashes.isEmpty {
            ctx?.setLineDash(phase: CGFloat(stroke.offset),
                             lengths: stroke.dashes.map { CGFloat($0) })
        }
    }

    internal class func setGeometry(_ locus: Locus, ctx: CGContext) {
        if let rect = locus as? Rect {
            ctx.addRect(rect.toCG())
        } else if let round = locus as? RoundRect {
            let corners = CGSize(width: CGFloat(round.rx), height: CGFloat(round.ry))
            let path = MBezierPath(roundedRect: round.rect.toCG(), byRoundingCorners:
                MRectCorner.allCorners, cornerRadii: corners).cgPath
            ctx.addPath(path)
        } else if let circle = locus as? Circle {
            let cx = circle.cx
            let cy = circle.cy
            let r = circle.r
            ctx.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        } else if let ellipse = locus as? Ellipse {
            let cx = ellipse.cx
            let cy = ellipse.cy
            let rx = ellipse.rx
            let ry = ellipse.ry
            ctx.addEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
        } else {
            ctx.addPath(locus.toCGPath())
        }
    }
}
