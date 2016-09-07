import Foundation
import UIKit

class ShapeRenderer: NodeRenderer {

	let shape: Shape

	let animationCache: AnimationCache

	init(shape: Shape, ctx: RenderContext, animationCache: AnimationCache) {
		self.shape = shape
		self.animationCache = animationCache
		super.init(node: shape, ctx: ctx)
	}

	override func node() -> Node {
		return shape
	}

	override func addObservers() {
		super.addObservers()
		observe(shape.formVar)
		observe(shape.fillVar)
		observe(shape.strokeVar)
	}

	override func render(force: Bool, opacity: Double) {

		if !force {
			// Cutting animated content
			if animationCache.isAnimating(shape) {
				return
			}
		}

		setGeometry(shape.form, ctx: ctx.cgContext!)
		drawPath(shape.fill, stroke: shape.stroke, ctx: ctx.cgContext!, opacity: opacity)
	}

	override func detectTouches(location: CGPoint) -> [Shape] {
		var touchedShapes = [Shape]()

		setGeometry(shape.form, ctx: ctx.cgContext!)

		var drawingMode: CGPathDrawingMode? = nil
		if let _ = shape.stroke, _ = shape.fill {
			drawingMode = .FillStroke
		} else if let _ = shape.stroke {
			drawingMode = .Stroke
		} else if let _ = shape.fill {
			drawingMode = .Fill
		}

		var contains = false
		if let mode = drawingMode {
			contains = CGContextPathContainsPoint(ctx.cgContext!, location, mode)
		}
		if contains {
			touchedShapes.append(shape)
		}

		// Prepare for next figure hittesting - clear current context path
		CGContextBeginPath(ctx.cgContext!)
		return touchedShapes
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
				let startAngle = CGFloat(arc.shift)
				let endAngle = startAngle + CGFloat(arc.extent)
				let r = CGFloat(ellipse.rx)
				let scale = CGFloat(ellipse.ry / ellipse.rx)

				let path = CGPathCreateMutable()
				var t = CGAffineTransformMakeTranslation(CGFloat(ellipse.cx), CGFloat(ellipse.cy))
				t = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, scale), t);
				CGPathAddArc(path, &t, 0, 0, r, startAngle, endAngle, false)
				CGContextAddPath(ctx, path)
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
		let shift = CGFloat(arc.shift)
		let end = shift + CGFloat(arc.extent)
		let ellipse = arc.ellipse
		let center = CGPointMake(CGFloat(ellipse.cx), CGFloat(ellipse.cy))
		return UIBezierPath(arcCenter: center, radius: CGFloat(ellipse.rx), startAngle: shift, endAngle: end, clockwise: true)
	}

	private func toBezierPath(points: [Double]) -> UIBezierPath {
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
			let data = part.data
			switch part.type {
			case .M:
				M(data[0], y: data[1])
			case .m:
				m(data[0], y: data[1])
			case .L:
				L(data[0], y: data[1])
			case .l:
				l(data[0], y: data[1])
			case .H:
				H(data[0])
			case .h:
				h(data[0])
			case .V:
				V(data[0])
			case .v:
				v(data[0])
			case .C:
				C(data[0], y1: data[1], x2: data[2], y2: data[3], x: data[4], y: data[5])
			case .c:
				c(data[0], y1: data[1], x2: data[2], y2: data[3], x: data[4], y: data[5])
			case .S:
				S(data[0], y2: data[1], x: data[2], y: data[3])
			case .s:
				s(data[0], y2: data[1], x: data[2], y: data[3])
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

	private func numToBools(num: Double) -> [Bool] {
		let val: Int = Int(num);
		return [(val & 1) > 0, (val & 2) > 0];
	}

	private func newCGRect(rect: Rect) -> CGRect {
		return CGRect(x: CGFloat(rect.x), y: CGFloat(rect.y), width: CGFloat(rect.w), height: CGFloat(rect.h))
	}

	private func drawPath(fill: Fill?, stroke: Stroke?, ctx: CGContext?, opacity: Double) {
		var shouldStrokePath = false
		if fill is Gradient || stroke?.fill is Gradient {
			shouldStrokePath = true
		}

		if let fill = fill, stroke = stroke {
			let path = CGContextCopyPath(ctx)
			setFill(fill, ctx: ctx, opacity: opacity)
			if stroke.fill is Gradient && !(fill is Gradient) {
				CGContextDrawPath(ctx, .Fill)
			}
			drawWithStroke(stroke, ctx: ctx, opacity: opacity, shouldStrokePath: shouldStrokePath, path: path, mode: .FillStroke)
			return
		}

		if let fill = fill {
			setFill(fill, ctx: ctx, opacity: opacity)
			CGContextDrawPath(ctx, .Fill)
			return
		}

		if let stroke = stroke {
			drawWithStroke(stroke, ctx: ctx, opacity: opacity, shouldStrokePath: shouldStrokePath, mode: .Stroke)
			return
		}

		CGContextSetLineWidth(ctx, 2.0)
		CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
		CGContextDrawPath(ctx, .Stroke)
	}

	private func setFill(fill: Fill?, ctx: CGContext?, opacity: Double) {
		guard let fill = fill else {
			return
		}
		if let fillColor = fill as? Color {
			let color = RenderUtils.applyOpacity(fillColor, opacity: opacity)
			CGContextSetFillColorWithColor(ctx, RenderUtils.mapColor(color))
		} else if let gradient = fill as? Gradient {
			drawGradient(gradient, ctx: ctx, opacity: opacity)
		} else {
			print("Unsupported fill: \(fill)")
		}
	}

	private func drawWithStroke(stroke: Stroke, ctx: CGContext?, opacity: Double, shouldStrokePath: Bool = false, path: CGPath? = nil, mode: CGPathDrawingMode) {
		if let path = path where shouldStrokePath {
			CGContextAddPath(ctx, path)
		}
		setStrokeAttributes(stroke, ctx: ctx)

		if stroke.fill is Gradient {
			gradientStroke(stroke, ctx: ctx, opacity: opacity)
			return
		} else if stroke.fill is Color {
			colorStroke(stroke, ctx: ctx, opacity: opacity)
		}
		if shouldStrokePath {
			CGContextStrokePath(ctx)
		} else {
			CGContextDrawPath(ctx, mode)
		}
	}

	private func setStrokeAttributes(stroke: Stroke, ctx: CGContext?) {
		CGContextSetLineWidth(ctx, CGFloat(stroke.width))
		CGContextSetLineJoin(ctx, RenderUtils.mapLineJoin(stroke.join))
		CGContextSetLineCap(ctx, RenderUtils.mapLineCap(stroke.cap))
		let dashes = stroke.dashes
		if !dashes.isEmpty {
			let dashPointer = RenderUtils.mapDash(dashes)
			CGContextSetLineDash(ctx, 0, dashPointer, dashes.count)
			dashPointer.dealloc(dashes.count)
		}
	}

	private func colorStroke(stroke: Stroke, ctx: CGContext?, opacity: Double) {
		guard let strokeColor = stroke.fill as? Color else {
			return
		}
		let color = RenderUtils.applyOpacity(strokeColor, opacity: opacity)
		CGContextSetStrokeColorWithColor(ctx, RenderUtils.mapColor(color))
	}
    
    private func gradientStroke(stroke: Stroke, ctx: CGContext?, opacity: Double) {
        guard let gradient = stroke.fill as? Gradient else {
            return
        }
        CGContextReplacePathWithStrokedPath(ctx)
        drawGradient(gradient, ctx: ctx, opacity: opacity)
    }
    
    private func drawGradient(gradient: Gradient, ctx: CGContext?, opacity: Double) {
        CGContextSaveGState(ctx)
        var colors: [CGColor] = []
        var stops: [CGFloat] = []
        for stop in gradient.stops {
            stops.append(CGFloat(stop.offset))
            let color = RenderUtils.applyOpacity(stop.color, opacity: opacity)
            colors.append(RenderUtils.mapColor(color))
        }
        
        if let gradient = gradient as? LinearGradient {
            var start = CGPointMake(CGFloat(gradient.x1), CGFloat(gradient.y1))
            var end = CGPointMake(CGFloat(gradient.x2), CGFloat(gradient.y2))
            if gradient.userSpace {
                let bounds = CGContextGetPathBoundingBox(ctx)
                start = CGPointMake(start.x * bounds.width + bounds.minX, start.y * bounds.height + bounds.minY)
                end = CGPointMake(end.x * bounds.width + bounds.minX, end.y * bounds.height + bounds.minY)
            }
            CGContextClip(ctx)
            let cgGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, stops)
            CGContextDrawLinearGradient(ctx, cgGradient, start, end, [.DrawsAfterEndLocation, .DrawsBeforeStartLocation])
        } else if let gradient = gradient as? RadialGradient {
            var innerCenter = CGPointMake(CGFloat(gradient.fx), CGFloat(gradient.fy))
            var outerCenter = CGPointMake(CGFloat(gradient.cx), CGFloat(gradient.cy))
            var radius = CGFloat(gradient.r)
            if gradient.userSpace {
                var bounds = CGContextGetPathBoundingBox(ctx)
                var scaleX: CGFloat = 1
                var scaleY: CGFloat = 1
                if bounds.width > bounds.height {
                    scaleY = bounds.height / bounds.width
                } else {
                    scaleX = bounds.width / bounds.height
                }
                CGContextScaleCTM(ctx, scaleX, scaleY)
                bounds = CGContextGetPathBoundingBox(ctx)
                innerCenter = CGPointMake(innerCenter.x * bounds.width + bounds.minX, innerCenter.y * bounds.height + bounds.minY)
                outerCenter = CGPointMake(outerCenter.x * bounds.width + bounds.minX, outerCenter.y * bounds.height + bounds.minY)
                radius = min(radius * bounds.width, radius * bounds.height)

            }
            CGContextClip(ctx)
            let cgGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, stops)
            CGContextDrawRadialGradient(ctx, cgGradient, innerCenter, 0, outerCenter, radius, [.DrawsAfterEndLocation, .DrawsBeforeStartLocation])
        }
        CGContextRestoreGState(ctx)
    }
    
}
