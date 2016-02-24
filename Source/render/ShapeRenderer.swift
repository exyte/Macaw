import Foundation
import UIKit

class ShapeRenderer: NodeRenderer {
    
    var ctx: RenderContext
    var node: Node {
        get { return shape }
    }
    let shape: Shape
    
    init(shape: Shape, ctx: RenderContext) {
        self.shape = shape
        self.ctx = ctx
        hook()
    }

    func render() {
        setGeometry(shape.form, ctx: ctx.cgContext!)
        setFill(shape.fill, ctx: ctx.cgContext!)
        setStroke(shape.stroke, ctx: ctx.cgContext!)
    }
    
    private func hook() {
        func onFormChange(old: Locus, new: Locus) {
            render()
            ctx.view.setNeedsDisplay()
        }
        shape.formProperty.addListener(onFormChange)
    }
    
    private func setGeometry(locus: Locus, ctx: CGContext) {
        if let rect = locus as? Rect {
            CGContextAddRect(ctx, newCGRect(rect))
        } else if let round = locus as? RoundRect {
            let corners = CGSizeMake(CGFloat(round.rx), CGFloat(round.ry))
            let path = UIBezierPath(roundedRect: newCGRect(round.rect), byRoundingCorners:
                UIRectCorner.AllCorners, cornerRadii: corners).CGPath
            CGContextAddPath(ctx, path)
        } else if let circle = locus as? Circle {
            let cx = circle.cx
            let cy = circle.cy
            let r = circle.r
            CGContextAddEllipseInRect(ctx, CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        } else if let ellipse = locus as? Ellipse {
            let cx = ellipse.cx
            let cy = ellipse.cy
            let rx = ellipse.rx
            let ry = ellipse.ry
            CGContextAddEllipseInRect(ctx, CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
        } else if let arc = locus as? Arc {
            if arc.ellipse.rx == arc.ellipse.ry {
                // Only circle arc supported for now
                CGContextAddPath(ctx, toBezierPath(arc).CGPath)
            } else {
                // http://stackoverflow.com/questions/11365775/how-to-draw-an-elliptical-arc-with-coregraphics
                // input parameters
                let ellipse = arc.ellipse
                let left = CGFloat(ellipse.cx - ellipse.cx / 2)
                let top = CGFloat(ellipse.cy - ellipse.cy / 2)
                let width = CGFloat(ellipse.cx * 2)
                let height = CGFloat(ellipse.ry * 2)
                let startAngle = CGFloat(arc.shift)
                let endAngle = startAngle + CGFloat(arc.extent)
                
                let cx = left + width * 0.5
                let cy = top + height * 0.5
                let r = CGFloat(width * 0.5)
                
                let path = CGPathCreateMutable()
                var t = CGAffineTransformMakeTranslation(cx, cy)
                t = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, height/width), t);
                CGPathAddArc(path, &t, 0, 0, r, startAngle, endAngle, false)
            
                CGContextAddPath(ctx, path)
                CGContextStrokePath(ctx)
            }
        } else if let point = locus as? Point {
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(CGFloat(point.x), CGFloat(point.y)))
            path.addLineToPoint(CGPointMake(CGFloat(point.x), CGFloat(point.y)))
            CGContextAddPath(ctx, path.CGPath)
        } else if let line = locus as? Line {
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(CGFloat(line.x1), CGFloat(line.y1)))
            path.addLineToPoint(CGPointMake(CGFloat(line.x2), CGFloat(line.y2)))
            CGContextAddPath(ctx, path.CGPath)
        } else if let polygon = locus as? Polygon {
            let path = toBezierPath(polygon.points)
            path.closePath()
            CGContextAddPath(ctx, path.CGPath)
        } else if let polygon = locus as? Polyline {
            CGContextAddPath(ctx, toBezierPath(polygon.points).CGPath)
        } else if let path = locus as? Path {
            CGContextAddPath(ctx, toBezierPath(path).CGPath)
        } else {
            print("Unsupported locus: \(locus)")
        }
    }
    
    private func toBezierPath(arc: Arc) -> UIBezierPath {
        let extent = CGFloat(arc.extent)
        let end = CGFloat(arc.shift) + extent
        let ellipse = arc.ellipse
        let center = CGPointMake(CGFloat(ellipse.cx), CGFloat(ellipse.cy))
        return UIBezierPath(arcCenter: center, radius: CGFloat(ellipse.rx), startAngle: extent, endAngle: end, clockwise: true)
    }
    
    private func toBezierPath(points: [Double]) -> UIBezierPath {
        let parts = 0.stride(to: points.count, by: 2).map { Array(points[$0..<$0 + 2]) }
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
    
    private func toBezierPath(path: Path) -> UIBezierPath {
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
            // XXX: implementx
        }
        
        func A(rx: Double, ry: Double, angle: Double, largeArc: Bool, sweep: Bool, x: Double, y: Double) {
            // XXX: implementx
        }
        
        func E(x: Double, y: Double, w: Double, h: Double, startAngle: Double, arcAngle: Double) {
            // TODO: only circle now
            let extent = CGFloat(startAngle)
            let end = extent + CGFloat(arcAngle)
            let center = CGPointMake(CGFloat(x + w/2), CGFloat(y + h/2))
            bezierPath.addArcWithCenter(center, radius: CGFloat(w/2), startAngle: extent, endAngle: end, clockwise: true)
        }
        
        func e(x: Double, y: Double, w: Double, h: Double, startAngle: Double, arcAngle: Double) {
            // TODO: only circle now
            if let cur = currentPoint {
                let extent = CGFloat(startAngle)
                let end = extent + CGFloat(arcAngle)
                let center = CGPointMake(CGFloat(x + w/2) + cur.x, CGFloat(y + h/2) + cur.y)
                bezierPath.addArcWithCenter(center, radius: CGFloat(w/2), startAngle: extent, endAngle: end, clockwise: true)
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
            if let move = part as? Move {
                if move.absolute {
                    M(move.x, y: move.y)
                } else {
                    m(move.x, y: move.y)
                }
                
            } else if let pline = part as? PLine {
                if pline.absolute {
                    L(pline.x, y: pline.y)
                } else {
                    l(pline.x, y: pline.y)
                }
            } else if let hLine = part as? HLine {
                if hLine.absolute {
                    H(hLine.x)
                } else {
                    h(hLine.x)
                }
            } else if let vLine = part as? VLine {
                if vLine.absolute {
                    V(vLine.y)
                } else {
                    v(vLine.y)
                }
            } else if let cubic = part as? Cubic {
                if cubic.absolute {
                    C(cubic.x1, y1: cubic.y1, x2: cubic.x2, y2: cubic.y2, x: cubic.x, y: cubic.y)
                } else {
                    c(cubic.x1, y1: cubic.y1, x2: cubic.x2, y2: cubic.y2, x: cubic.x, y: cubic.y)
                }
            } else if let scubic = part as? SCubic {
                if scubic.absolute {
                    S(scubic.x2, y2: scubic.y2, x: scubic.x, y: scubic.y)
                } else {
                    s(scubic.x2, y2: scubic.y2, x: scubic.x, y: scubic.y)
                }
            } else if let elliptical = part as? Elliptical {
                if elliptical.absolute {
                    A(elliptical.rx, ry: elliptical.ry, angle: elliptical.angle, largeArc: elliptical.largeArc, sweep: elliptical.sweep, x: elliptical.x, y: elliptical.y)
                } else {
                    a(elliptical.rx, ry: elliptical.ry, angle: elliptical.angle, largeArc: elliptical.largeArc, sweep: elliptical.sweep, x: elliptical.x, y: elliptical.y)
                }
            } else if let _ = part as? Close {
                Z()
            }
        }
        return bezierPath
    }
    
    private func newCGRect(rect: Rect) -> CGRect {
        return CGRect(x: CGFloat(rect.x), y: CGFloat(rect.y), width: CGFloat(rect.w), height: CGFloat(rect.h))
    }
    
    private func setFill(fill: Fill?, ctx: CGContext?) {
        if fill != nil {
            if let color = fill as? Color {
                CGContextSetFillColorWithColor(ctx, RenderUtils.mapColor(color))
                CGContextFillPath(ctx)
            } else if let gradient = fill as? LinearGradient {
                var start = CGPointMake(CGFloat(gradient.x1), CGFloat(gradient.y1))
                var end = CGPointMake(CGFloat(gradient.x2), CGFloat(gradient.y2))
                if gradient.userSpace {
                    let bounds = CGContextGetPathBoundingBox(ctx)
                    start = CGPointMake(start.x * bounds.width + bounds.minX, start.y * bounds.height + bounds.minY)
                    end = CGPointMake(end.x * bounds.width + bounds.minX, end.y * bounds.height + bounds.minY)
                }
                var colors: [CGColor] = []
                var stops: [CGFloat] = []
                for stop in gradient.stops {
                    stops.append(CGFloat(stop.offset))
                    colors.append(RenderUtils.mapColor(stop.color))
                }
                let cgGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, stops)
                CGContextClip(ctx)
                CGContextDrawLinearGradient(ctx, cgGradient, start, end, CGGradientDrawingOptions.DrawsAfterEndLocation)
            } else {
                print("Unsupported fill: \(fill)")
            }
        }
    }
    
    
    private func setStroke(stroke: Stroke?, ctx: CGContext?) {
        if stroke != nil {
            if let color = stroke!.fill as? Color {
                CGContextSetLineWidth(ctx, CGFloat(stroke!.width))
                CGContextSetLineJoin(ctx, RenderUtils.mapLineJoin(stroke!.join))
                CGContextSetLineCap(ctx, RenderUtils.mapLineCap(stroke!.cap))
                let dashes = stroke!.dashes
                if !dashes.isEmpty {
                    let dashPointer = RenderUtils.mapDash(dashes)
                    CGContextSetLineDash(ctx, 0, dashPointer, dashes.count)
                    dashPointer.dealloc(dashes.count)
                }
                CGContextSetStrokeColorWithColor(ctx, RenderUtils.mapColor(color))
                CGContextStrokePath(ctx)
            } else {
                print("Unsupported stroke fill: \(stroke!.fill)")
            }
        }
    }

}
