import Foundation
import UIKit

class RenderUtils {
	class func mapColor(color: Color) -> CGColor {
		let red = CGFloat(Double(color.r()) / 255.0)
		let green = CGFloat(Double(color.g()) / 255.0)
		let blue = CGFloat(Double(color.b()) / 255.0)
		let alpha = CGFloat(Double(color.a()) / 255.0)
		return UIColor(red: red, green: green, blue: blue, alpha: alpha).CGColor
	}

	class func mapTransform(t: Transform) -> CGAffineTransform {
		return CGAffineTransform(a: CGFloat(t.m11), b: CGFloat(t.m12), c: CGFloat(t.m21),
			d: CGFloat(t.m22), tx: CGFloat(t.dx), ty: CGFloat(t.dy))
	}

	class func mapLineJoin(join: LineJoin?) -> CGLineJoin {
		switch join {
		case LineJoin.round?: return CGLineJoin.Round
		case LineJoin.bevel?: return CGLineJoin.Bevel
		default: return CGLineJoin.Miter
		}
	}

	class func mapLineCap(cap: LineCap?) -> CGLineCap {
		switch cap {
		case LineCap.round?: return CGLineCap.Round
		case LineCap.square?: return CGLineCap.Square
		default: return CGLineCap.Butt
		}
	}

	class func mapDash(dashes: [Double]) -> UnsafeMutablePointer<CGFloat> {
		let p = UnsafeMutablePointer<CGFloat>(calloc(dashes.count, sizeof(CGFloat)))
		for (index, item) in dashes.enumerate() {
			p[index] = CGFloat(item)
		}
		return p
	}

	class func createNodeRenderer(node: Node, context: RenderContext, animationCache: AnimationCache) -> NodeRenderer {
		if let group = node as? Group {
			return GroupRenderer(group: group, ctx: context, animationCache: animationCache)
		} else if let shape = node as? Shape {
			return ShapeRenderer(shape: shape, ctx: context, animationCache: animationCache)
		} else if let text = node as? Text {
			return TextRenderer(text: text, ctx: context, animationCache: animationCache)
		} else if let image = node as? Image {
			return ImageRenderer(image: image, ctx: context, animationCache: animationCache)
		}
		fatalError("Unsupported node: \(node)");
	}

	class func applyOpacity(color: Color, opacity: Double) -> Color {
		return Color.rgba(r: color.r(), g: color.g(), b: color.b(), a: Double(color.a()) / 255.0 * opacity)
	}

    class func toCGPath(locus: Locus) -> CGPath {
        if let arc = locus as? Arc {
            if arc.ellipse.rx != arc.ellipse.ry {
                // http://stackoverflow.com/questions/11365775/how-to-draw-an-elliptical-arc-with-coregraphics
                // input parameters
                let ellipse = arc.ellipse
                let startAngle = CGFloat(arc.shift)
                let endAngle = startAngle + CGFloat(arc.extent)
                let r = CGFloat(ellipse.rx)
                let scale = CGFloat(ellipse.ry / ellipse.rx)
                let path = CGPathCreateMutable()
                var t = CGAffineTransformMakeTranslation(CGFloat(ellipse.cx), CGFloat(ellipse.cy))
                t = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, scale), t)
                CGPathAddArc(path, &t, 0, 0, r, startAngle, endAngle, false)
                return path
            }
        }
        return toBezierPath(locus).CGPath
    }
    
    class func toBezierPath(locus: Locus) -> UIBezierPath {
        if let round = locus as? RoundRect {
            let corners = CGSizeMake(CGFloat(round.rx), CGFloat(round.ry))
            return UIBezierPath(roundedRect: newCGRect(round.rect), byRoundingCorners:
                UIRectCorner.AllCorners, cornerRadii: corners)
        } else if let arc = locus as? Arc {
            if arc.ellipse.rx == arc.ellipse.ry {
                return arcToPath(arc)
            }
        } else if let point = locus as? Point {
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(CGFloat(point.x), CGFloat(point.y)))
            path.addLineToPoint(CGPointMake(CGFloat(point.x), CGFloat(point.y)))
            return path
        } else if let line = locus as? Line {
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(CGFloat(line.x1), CGFloat(line.y1)))
            path.addLineToPoint(CGPointMake(CGFloat(line.x2), CGFloat(line.y2)))
            return path
        } else if let polygon = locus as? Polygon {
            let path = pointsToPath(polygon.points)
            path.closePath()
            return path
        } else if let polygon = locus as? Polyline {
            return pointsToPath(polygon.points)
        } else if let path = locus as? Path {
            return toBezierPath(path)
        }
        fatalError("Unsupported locus: \(locus)")
    }

    private class func arcToPath(arc: Arc) -> UIBezierPath {
        let shift = CGFloat(arc.shift)
        let end = shift + CGFloat(arc.extent)
        let ellipse = arc.ellipse
        let center = CGPointMake(CGFloat(ellipse.cx), CGFloat(ellipse.cy))
        return UIBezierPath(arcCenter: center, radius: CGFloat(ellipse.rx), startAngle: shift, endAngle: end, clockwise: true)
    }

    private class func pointsToPath(points: [Double]) -> UIBezierPath {
        let parts = 0.stride(to: points.count, by: 2).map { Array(points[$0 ..< $0 + 2]) }
        let path = UIBezierPath()
        var first = true
        for part in parts {
            let point = CGPointMake(CGFloat(part[0]), CGFloat(part[1]))
            if (first) {
                path.moveToPoint(point)
                first = false
            } else {
                path.addLineToPoint(point)
            }
        }
        return path
    }

    private class func toBezierPath(path: Path) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        var currentPoint: CGPoint?
        var cubicPoint: CGPoint?
        var quadrPoint: CGPoint?
        var initialPoint: CGPoint?
        
        func M(x: Double, y: Double) {
            let point = CGPointMake(CGFloat(x), CGFloat(y))
            bezierPath.moveToPoint(point)
            setInitPoint(point)
        }
        
        func m(x: Double, y: Double) {
            if let cur = currentPoint {
                let next = CGPointMake(CGFloat(x) + cur.x, CGFloat(y) + cur.y)
                bezierPath.moveToPoint(next)
                setInitPoint(next)
            } else {
                M(x, y: y)
            }
        }
        
        func L(x: Double, y: Double) {
            lineTo(CGPointMake(CGFloat(x), CGFloat(y)))
        }
        
        func l(x: Double, y: Double) {
            if let cur = currentPoint {
                lineTo(CGPointMake(CGFloat(x) + cur.x, CGFloat(y) + cur.y))
            } else {
                L(x, y: y)
            }
        }
        
        func H(x: Double) {
            if let cur = currentPoint {
                lineTo(CGPointMake(CGFloat(x), CGFloat(cur.y)))
            }
        }
        
        func h(x: Double) {
            if let cur = currentPoint {
                lineTo(CGPointMake(CGFloat(x) + cur.x, CGFloat(cur.y)))
            }
        }
        
        func V(y: Double) {
            if let cur = currentPoint {
                lineTo(CGPointMake(CGFloat(cur.x), CGFloat(y)))
            }
        }
        
        func v(y: Double) {
            if let cur = currentPoint {
                lineTo(CGPointMake(CGFloat(cur.x), CGFloat(y) + cur.y))
            }
        }
        
        func lineTo(p: CGPoint) {
            bezierPath.addLineToPoint(p)
            setPoint(p)
        }
        
        func c(x1: Double, y1: Double, x2: Double, y2: Double, x: Double, y: Double) {
            if let cur = currentPoint {
                let endPoint = CGPointMake(CGFloat(x) + cur.x, CGFloat(y) + cur.y)
                let controlPoint1 = CGPointMake(CGFloat(x1) + cur.x, CGFloat(y1) + cur.y)
                let controlPoint2 = CGPointMake(CGFloat(x2) + cur.x, CGFloat(y2) + cur.y)
                bezierPath.addCurveToPoint(endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                setCubicPoint(endPoint, cubic: controlPoint2)
            }
        }
        
        func C(x1: Double, y1: Double, x2: Double, y2: Double, x: Double, y: Double) {
            let endPoint = CGPointMake(CGFloat(x), CGFloat(y))
            let controlPoint1 = CGPointMake(CGFloat(x1), CGFloat(y1))
            let controlPoint2 = CGPointMake(CGFloat(x2), CGFloat(y2))
            bezierPath.addCurveToPoint(endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            setCubicPoint(endPoint, cubic: controlPoint2)
        }
        
        func s(x2: Double, y2: Double, x: Double, y: Double) {
            if let cur = currentPoint {
                let nextCubic = CGPointMake(CGFloat(x2) + cur.x, CGFloat(y2) + cur.y)
                let next = CGPointMake(CGFloat(x) + cur.x, CGFloat(y) + cur.y)
                
                var xy1: CGPoint?
                if let curCubicVal = cubicPoint {
                    xy1 = CGPointMake(CGFloat(2 * cur.x) - curCubicVal.x, CGFloat(2 * cur.y) - curCubicVal.y)
                } else {
                    xy1 = cur
                }
                bezierPath.addCurveToPoint(next, controlPoint1: xy1!, controlPoint2: nextCubic)
                setCubicPoint(next, cubic: nextCubic)
            }
        }
        
        func S(x2: Double, y2: Double, x: Double, y: Double) {
            if let cur = currentPoint {
                let nextCubic = CGPointMake(CGFloat(x2), CGFloat(y2))
                let next = CGPointMake(CGFloat(x), CGFloat(y))
                var xy1: CGPoint?
                if let curCubicVal = cubicPoint {
                    xy1 = CGPointMake(CGFloat(2 * cur.x) - curCubicVal.x, CGFloat(2 * cur.y) - curCubicVal.y)
                } else {
                    xy1 = cur
                }
                bezierPath.addCurveToPoint(next, controlPoint1: xy1!, controlPoint2: nextCubic)
                setCubicPoint(next, cubic: nextCubic)
            }
        }
        
        func a(rx: Double, ry: Double, angle: Double, largeArc: Bool, sweep: Bool, x: Double, y: Double) {
            if let cur = currentPoint {
                A(rx, ry: ry, angle: angle, largeArc: largeArc, sweep: sweep, x: x + Double(cur.x), y: y + Double(cur.y))
            }
        }
        
        func A(rx: Double, ry: Double, angle: Double, largeArc: Bool, sweep: Bool, x: Double, y: Double) {
            if let cur = currentPoint {
                let x1 = Double(cur.x)
                let y1 = Double(cur.y)
                
                // find arc center coordinates and points angles as per
                // http://www.w3.org/TR/SVG/implnote.html#ArcConversionEndpointToCenter
                let x1_ = cos(angle) * (x1 - x) / 2 + sin(angle) * (y1 - y) / 2;
                let y1_ = -1 * sin(angle) * (x1 - x) / 2 + cos(angle) * (y1 - y) / 2;
                // make sure the value under the root is positive
                let underroot = (rx * rx * ry * ry - rx * rx * y1_ * y1_ - ry * ry * x1_ * x1_)
                    / (rx * rx * y1_ * y1_ + ry * ry * x1_ * x1_);
                var bigRoot = (underroot > 0) ? sqrt(underroot) : 0;
                // TODO: Replace concrete number with 1e-2
                bigRoot = (bigRoot <= 0.01) ? 0 : bigRoot;
                let coef: Double = (sweep != largeArc) ? 1 : -1;
                let cx_ = coef * bigRoot * rx * y1_ / ry;
                let cy_ = -1 * coef * bigRoot * ry * x1_ / rx;
                let cx = (cos(angle) * cx_ - sin(angle) * cy_ + (x1 + x) / 2);
                let cy = (sin(angle) * cx_ + cos(angle) * cy_ + (y1 + y) / 2);
                let t1 = -1 * atan2(y1 - cy, x1 - cx);
                let t2 = atan2(y - cy, x - cx);
                var delta = -(t1 + t2);
                // recalculate delta depending on arc. Preserve rotation direction
                if (largeArc) {
                    let sg = copysign(1.0, delta);
                    if (abs(delta) < M_PI) {
                        delta = -1 * (sg * M_2_PI - delta);
                    }
                } else {
                    let sg = copysign(1.0, delta);
                    if (abs(delta) > M_PI) {
                        delta = -1 * (sg * M_2_PI - delta);
                    }
                }
                E(cx - rx, y: cy - ry, w: 2 * rx, h: 2 * ry, startAngle: t1, arcAngle: delta);
                setPoint(CGPointMake(CGFloat(x), CGFloat(y)))
            }
        }
        
        func E(x: Double, y: Double, w: Double, h: Double, startAngle: Double, arcAngle: Double) {
            // TODO: only circle now
            let extent = CGFloat(startAngle)
            let end = extent + CGFloat(arcAngle)
            let center = CGPointMake(CGFloat(x + w / 2), CGFloat(y + h / 2))
            bezierPath.addArcWithCenter(center, radius: CGFloat(w / 2), startAngle: extent, endAngle: end, clockwise: true)
        }
        
        func e(x: Double, y: Double, w: Double, h: Double, startAngle: Double, arcAngle: Double) {
            // TODO: only circle now
            if let cur = currentPoint {
                E(x + Double(cur.x), y: y + Double(cur.y), w: w, h: h, startAngle: startAngle, arcAngle: arcAngle)
            }
        }
        
        func Z() {
            if let initPoint = initialPoint {
                lineTo(initPoint)
            }
            bezierPath.closePath()
        }
        
        func setCubicPoint(p: CGPoint, cubic: CGPoint) {
            currentPoint = p
            cubicPoint = cubic
            quadrPoint = nil
        }
        
        func setInitPoint(p: CGPoint) {
            setPoint(p)
            initialPoint = p
        }
        
        func setPoint(p: CGPoint) {
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
                data.removeRange(Range(start: 0, end: 2))
                while data.count >= 2 {
                    L(data[0], y: data[1])
                    data.removeRange(Range(start: 0, end: 2))
                }
            case .m:
                m(data[0], y: data[1])
                data.removeRange(Range(start: 0, end: 2))
                while data.count >= 2 {
                    l(data[0], y: data[1])
                    data.removeRange(Range(start: 0, end: 2))
                }
            case .L:
                while data.count >= 2 {
                    L(data[0], y: data[1])
                    data.removeRange(Range(start: 0, end: 2))
                }
            case .l:
                while data.count >= 2 {
                    l(data[0], y: data[1])
                    data.removeRange(Range(start: 0, end: 2))
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
                    data.removeRange(Range(start: 0, end: 6))
                }
            case .c:
                while data.count >= 6 {
                    c(data[0], y1: data[1], x2: data[2], y2: data[3], x: data[4], y: data[5])
                    data.removeRange(Range(start: 0, end: 6))
                }
            case .S:
                while data.count >= 4 {
                    S(data[0], y2: data[1], x: data[2], y: data[3])
                    data.removeRange(Range(start: 0, end: 4))
                }
            case .s:
                while data.count >= 4 {
                    s(data[0], y2: data[1], x: data[2], y: data[3])
                    data.removeRange(Range(start: 0, end: 4))
                }
            case .A:
                let flags = numToBools(data[3])
                A(data[0], ry: data[1], angle: data[2], largeArc: flags[0], sweep: flags[1], x: data[4], y: data[5])
            case .a:
                let flags = numToBools(data[3])
                a(data[0], ry: data[1], angle: data[2], largeArc: flags[0], sweep: flags[1], x: data[4], y: data[5])
            case .Z:
                Z()
            default:
                fatalError("Unknown segment: \(part.type)")
            }
        }
        return bezierPath
    }

    private class func numToBools(num: Double) -> [Bool] {
        let val: Int = Int(num);
        return [(val & 1) > 0, (val & 2) > 0];
    }

    private class func newCGRect(rect: Rect) -> CGRect {
        return CGRect(x: CGFloat(rect.x), y: CGFloat(rect.y), width: CGFloat(rect.w), height: CGFloat(rect.h))
    }

}
