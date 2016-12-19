import Foundation
import UIKit

class ShapeRenderer: NodeRenderer {

	let shape: Shape

	init(shape: Shape, ctx: RenderContext, animationCache: AnimationCache) {
		self.shape = shape
		super.init(node: shape, ctx: ctx, animationCache: animationCache)
	}

	override func node() -> Node {
		return shape
	}

	override func doAddObservers() {
		super.doAddObservers()
		observe(shape.formVar)
		observe(shape.fillVar)
		observe(shape.strokeVar)
	}

	override func doRender(_ force: Bool, opacity: Double) {
		setGeometry(shape.form, ctx: ctx.cgContext!)
		drawPath(shape.fill, stroke: shape.stroke, ctx: ctx.cgContext!, opacity: opacity)
	}

	override func doFindNodeAt(location: CGPoint) -> Node? {
		setGeometry(shape.form, ctx: ctx.cgContext!)

		var drawingMode: CGPathDrawingMode? = nil
		if let _ = shape.stroke, let _ = shape.fill {
			drawingMode = .fillStroke
		} else if let _ = shape.stroke {
			drawingMode = .stroke
		} else if let _ = shape.fill {
			drawingMode = .fill
		}
        
        var contains = false
        if let mode = drawingMode {
            contains = ctx.cgContext!.pathContains(CGPoint(x: location.x, y: location.y), mode: mode)
            
            if contains {
                return node()
            }
        }

		// Prepare for next figure hittesting - clear current context path
		ctx.cgContext!.beginPath()
		return .none
	}

	fileprivate func setGeometry(_ locus: Locus, ctx: CGContext) {
		if let rect = locus as? Rect {
			ctx.addRect(newCGRect(rect))
		} else if let round = locus as? RoundRect {
			let corners = CGSize(width: CGFloat(round.rx), height: CGFloat(round.ry))
			let path = UIBezierPath(roundedRect: newCGRect(round.rect), byRoundingCorners:
					UIRectCorner.allCorners, cornerRadii: corners).cgPath
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
            ctx.addPath(RenderUtils.toCGPath(locus))
		}
	}

	fileprivate func toBezierPath(_ arc: Arc) -> UIBezierPath {
		let shift = CGFloat(arc.shift)
		let end = shift + CGFloat(arc.extent)
		let ellipse = arc.ellipse
		let center = CGPoint(x: CGFloat(ellipse.cx), y: CGFloat(ellipse.cy))
		return UIBezierPath(arcCenter: center, radius: CGFloat(ellipse.rx), startAngle: shift, endAngle: end, clockwise: true)
	}

	fileprivate func toBezierPath(_ points: [Double]) -> UIBezierPath {
		let parts = stride(from: 0, to: points.count, by: 2).map { Array(points[$0 ..< $0 + 2]) }
		let path = UIBezierPath()
		var first = true
		for part in parts {
			let point = CGPoint(x: CGFloat(part[0]), y: CGFloat(part[1]))
			if (first) {
				path.move(to: point)
				first = false
			} else {
				path.addLine(to: point)
			}
		}
		return path
	}

	fileprivate func toBezierPath(_ path: Path) -> UIBezierPath {
		let bezierPath = UIBezierPath()

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

		func a(_ rx: Double, ry: Double, angle: Double, largeArc: Bool, sweep: Bool, x: Double, y: Double) {
			if let cur = currentPoint {
				A(rx, ry: ry, angle: angle, largeArc: largeArc, sweep: sweep, x: x + Double(cur.x), y: y + Double(cur.y))
			}
		}

		func A(_ rx: Double, ry: Double, angle: Double, largeArc: Bool, sweep: Bool, x: Double, y: Double) {
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
				setPoint(CGPoint(x: CGFloat(x), y: CGFloat(y)))
			}
		}

		func E(_ x: Double, y: Double, w: Double, h: Double, startAngle: Double, arcAngle: Double) {
			// TODO: only circle now
			let extent = CGFloat(startAngle)
			let end = extent + CGFloat(arcAngle)
			let center = CGPoint(x: CGFloat(x + w / 2), y: CGFloat(y + h / 2))
			bezierPath.addArc(withCenter: center, radius: CGFloat(w / 2), startAngle: extent, endAngle: end, clockwise: true)
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
                data.removeSubrange((0 ..< 2))
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
			case .A:
				let flags = numToBools(data[3])
				A(data[0], ry: data[1], angle: data[2], largeArc: flags[0], sweep: flags[1], x: data[4], y: data[5])
			case .a:
				let flags = numToBools(data[3])
				a(data[0], ry: data[1], angle: data[2], largeArc: flags[0], sweep: flags[1], x: data[4], y: data[5])
			case .z:
				Z()
			default:
				fatalError("Unknown segment: \(part.type)")
			}
		}
		return bezierPath
	}

	fileprivate func numToBools(_ num: Double) -> [Bool] {
		let val: Int = Int(num);
		return [(val & 1) > 0, (val & 2) > 0];
	}

	fileprivate func newCGRect(_ rect: Rect) -> CGRect {
		return CGRect(x: CGFloat(rect.x), y: CGFloat(rect.y), width: CGFloat(rect.w), height: CGFloat(rect.h))
	}

	fileprivate func drawPath(_ fill: Fill?, stroke: Stroke?, ctx: CGContext?, opacity: Double) {
		var shouldStrokePath = false
		if fill is Gradient || stroke?.fill is Gradient {
			shouldStrokePath = true
		}

		if let fill = fill, let stroke = stroke {
			let path = ctx!.path
			setFill(fill, ctx: ctx, opacity: opacity)
			if stroke.fill is Gradient && !(fill is Gradient) {
				ctx!.drawPath(using: .fill)
			}
			drawWithStroke(stroke, ctx: ctx, opacity: opacity, shouldStrokePath: shouldStrokePath, path: path, mode: .fillStroke)
			return
		}

		if let fill = fill {
			setFill(fill, ctx: ctx, opacity: opacity)
			ctx!.drawPath(using: .fill)
			return
		}

		if let stroke = stroke {
			drawWithStroke(stroke, ctx: ctx, opacity: opacity, shouldStrokePath: shouldStrokePath, mode: .stroke)
			return
		}

		ctx!.setLineWidth(2.0)
		ctx!.setStrokeColor(UIColor.black.cgColor)
		ctx!.drawPath(using: .stroke)
	}

	fileprivate func setFill(_ fill: Fill?, ctx: CGContext?, opacity: Double) {
		guard let fill = fill else {
			return
		}
		if let fillColor = fill as? Color {
			let color = RenderUtils.applyOpacity(fillColor, opacity: opacity)
			ctx!.setFillColor(RenderUtils.mapColor(color))
		} else if let gradient = fill as? Gradient {
			drawGradient(gradient, ctx: ctx, opacity: opacity)
		} else {
			print("Unsupported fill: \(fill)")
		}
	}

	fileprivate func drawWithStroke(_ stroke: Stroke, ctx: CGContext?, opacity: Double, shouldStrokePath: Bool = false, path: CGPath? = nil, mode: CGPathDrawingMode) {
		if let path = path , shouldStrokePath {
			ctx!.addPath(path)
		}
		setStrokeAttributes(stroke, ctx: ctx)

		if stroke.fill is Gradient {
			gradientStroke(stroke, ctx: ctx, opacity: opacity)
			return
		} else if stroke.fill is Color {
			colorStroke(stroke, ctx: ctx, opacity: opacity)
		}
		if shouldStrokePath {
			ctx!.strokePath()
		} else {
			ctx!.drawPath(using: mode)
		}
	}

	fileprivate func setStrokeAttributes(_ stroke: Stroke, ctx: CGContext?) {
		ctx!.setLineWidth(CGFloat(stroke.width))
		ctx!.setLineJoin(RenderUtils.mapLineJoin(stroke.join))
		ctx!.setLineCap(RenderUtils.mapLineCap(stroke.cap))
		let dashes = stroke.dashes
		if !dashes.isEmpty {
            var floatDashes = [CGFloat]()
            dashes.forEach { dash in
                floatDashes.append(CGFloat(dash))
            }
            
            ctx?.setLineDash(phase: 0.0, lengths: floatDashes)
		}
	}

	fileprivate func colorStroke(_ stroke: Stroke, ctx: CGContext?, opacity: Double) {
		guard let strokeColor = stroke.fill as? Color else {
			return
		}
		let color = RenderUtils.applyOpacity(strokeColor, opacity: opacity)
		ctx!.setStrokeColor(RenderUtils.mapColor(color))
	}

	fileprivate func gradientStroke(_ stroke: Stroke, ctx: CGContext?, opacity: Double) {
		guard let gradient = stroke.fill as? Gradient else {
			return
		}
		ctx!.replacePathWithStrokedPath()
		drawGradient(gradient, ctx: ctx, opacity: opacity)
	}

	fileprivate func drawGradient(_ gradient: Gradient, ctx: CGContext?, opacity: Double) {
		ctx!.saveGState()
		var colors: [CGColor] = []
		var stops: [CGFloat] = []
		for stop in gradient.stops {
			stops.append(CGFloat(stop.offset))
			let color = RenderUtils.applyOpacity(stop.color, opacity: opacity)
			colors.append(RenderUtils.mapColor(color))
		}

		if let gradient = gradient as? LinearGradient {
			var start = CGPoint(x: CGFloat(gradient.x1), y: CGFloat(gradient.y1))
			var end = CGPoint(x: CGFloat(gradient.x2), y: CGFloat(gradient.y2))
			if !gradient.userSpace {
				let bounds = ctx!.boundingBoxOfPath
				start = CGPoint(x: start.x * bounds.width + bounds.minX, y: start.y * bounds.height + bounds.minY)
				end = CGPoint(x: end.x * bounds.width + bounds.minX, y: end.y * bounds.height + bounds.minY)
			}
			ctx!.clip()
			let cgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: stops)
			ctx!.drawLinearGradient(cgGradient!, start: start, end: end, options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
		} else if let gradient = gradient as? RadialGradient {
			var innerCenter = CGPoint(x: CGFloat(gradient.fx), y: CGFloat(gradient.fy))
			var outerCenter = CGPoint(x: CGFloat(gradient.cx), y: CGFloat(gradient.cy))
			var radius = CGFloat(gradient.r)
			if !gradient.userSpace {
				var bounds = ctx!.boundingBoxOfPath
				var scaleX: CGFloat = 1
				var scaleY: CGFloat = 1
				if bounds.width > bounds.height {
					scaleY = bounds.height / bounds.width
				} else {
					scaleX = bounds.width / bounds.height
				}
				ctx!.scaleBy(x: scaleX, y: scaleY)
				bounds = ctx!.boundingBoxOfPath
				innerCenter = CGPoint(x: innerCenter.x * bounds.width + bounds.minX, y: innerCenter.y * bounds.height + bounds.minY)
				outerCenter = CGPoint(x: outerCenter.x * bounds.width + bounds.minX, y: outerCenter.y * bounds.height + bounds.minY)
				radius = min(radius * bounds.width, radius * bounds.height)

			}
			ctx!.clip()
			let cgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: stops)
			ctx!.drawRadialGradient(cgGradient!, startCenter: innerCenter, startRadius: 0, endCenter: outerCenter, endRadius: radius, options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
		}
		ctx!.restoreGState()
	}

}
