import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class ShapeRenderer: NodeRenderer {

    weak var shape: Shape?

    init(shape: Shape, view: MView?, animationCache: AnimationCache?) {
        self.shape = shape
        super.init(node: shape, view: view, animationCache: animationCache)
    }

    override func node() -> Node? {
        return shape
    }

    override func doAddObservers() {
        super.doAddObservers()

        guard let shape = shape else {
            return
        }

        observe(shape.formVar)
        observe(shape.fillVar)
        observe(shape.strokeVar)
    }

    override func doRender(in context: CGContext, force: Bool, opacity: Double, useAlphaOnly: Bool = false) {
        guard let shape = shape else {
            return
        }
        if shape.fill == nil && shape.stroke == nil {
            return
        }

        setGeometry(shape.form, ctx: context)

        var fillRule = FillRule.nonzero
        if let path = shape.form as? Path {
            fillRule = path.fillRule
        }

        if !useAlphaOnly {
            drawPath(fill: shape.fill, stroke: shape.stroke, ctx: context, opacity: opacity, fillRule: fillRule)
        } else {
            drawPath(fill: shape.fill?.fillUsingAlphaOnly(), stroke: shape.stroke?.strokeUsingAlphaOnly(), ctx: context, opacity: opacity, fillRule: fillRule)
        }
    }

    override func doFindNodeAt(location: CGPoint, ctx: CGContext) -> Node? {
        guard let shape = shape else {
            return .none
        }

        setGeometry(shape.form, ctx: ctx)
        var drawingMode: CGPathDrawingMode? = nil
        if let stroke = shape.stroke {
            setStrokeAttributes(stroke, ctx: ctx)
            if shape.fill != nil {
                drawingMode = .fillStroke
            } else {
                drawingMode = .stroke
            }
        } else {
            drawingMode = .fill
        }

        var contains = false
        if let mode = drawingMode {
            contains = ctx.pathContains(CGPoint(x: location.x, y: location.y), mode: mode)

            if contains {
                return node()
            }
        }

        // Prepare for next figure hittesting - clear current context path
        ctx.beginPath()
        return .none
    }

    fileprivate func setGeometry(_ locus: Locus, ctx: CGContext) {
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

    fileprivate func drawPath(fill: Fill?, stroke: Stroke?, ctx: CGContext?, opacity: Double, fillRule: FillRule) {
        var shouldStrokePath = false
        if fill is Gradient || stroke?.fill is Gradient {
            shouldStrokePath = true
        }

        if let fill = fill, let stroke = stroke {
            let path = ctx!.path
            setFill(fill, ctx: ctx, opacity: opacity)
            if stroke.fill is Gradient && !(fill is Gradient) {
                ctx!.drawPath(using: fillRule == .nonzero ? .fill : .eoFill)
            }
            drawWithStroke(stroke, ctx: ctx, opacity: opacity, shouldStrokePath: shouldStrokePath, path: path, mode: fillRule == .nonzero ? .fillStroke : .eoFillStroke)
            return
        }

        if let fill = fill {
            setFill(fill, ctx: ctx, opacity: opacity)
            ctx!.drawPath(using: fillRule == .nonzero ? .fill : .eoFill)
            return
        }

        if let stroke = stroke {
            drawWithStroke(stroke, ctx: ctx, opacity: opacity, shouldStrokePath: shouldStrokePath, mode: .stroke)
            return
        }
    }

    fileprivate func setFill(_ fill: Fill?, ctx: CGContext?, opacity: Double) {
        guard let fill = fill else {
            return
        }
        if let fillColor = fill as? Color {
            let color = RenderUtils.applyOpacity(fillColor, opacity: opacity)
            ctx!.setFillColor(color.toCG())
        } else if let gradient = fill as? Gradient {
            drawGradient(gradient, ctx: ctx, opacity: opacity)
        } else if let pattern = fill as? Pattern {
            drawPattern(pattern, ctx: ctx, opacity: opacity)
        } else {
            print("Unsupported fill: \(fill)")
        }
    }

    fileprivate func drawWithStroke(_ stroke: Stroke, ctx: CGContext?, opacity: Double, shouldStrokePath: Bool = false, path: CGPath? = nil, mode: CGPathDrawingMode) {
        if let path = path, shouldStrokePath {
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
        ctx!.setLineJoin(stroke.join.toCG())
        ctx!.setLineCap(stroke.cap.toCG())
        ctx!.setMiterLimit(CGFloat(stroke.miterLimit))
        if !stroke.dashes.isEmpty {
            ctx?.setLineDash(phase: CGFloat(stroke.offset),
                             lengths: stroke.dashes.map { CGFloat($0) })
        }
    }

    fileprivate func colorStroke(_ stroke: Stroke, ctx: CGContext?, opacity: Double) {
        guard let strokeColor = stroke.fill as? Color else {
            return
        }
        let color = RenderUtils.applyOpacity(strokeColor, opacity: opacity)
        ctx!.setStrokeColor(color.toCG())
    }

    fileprivate func gradientStroke(_ stroke: Stroke, ctx: CGContext?, opacity: Double) {
        guard let gradient = stroke.fill as? Gradient else {
            return
        }
        ctx!.replacePathWithStrokedPath()
        drawGradient(gradient, ctx: ctx, opacity: opacity)
    }

    fileprivate func drawPattern(_ pattern: Pattern, ctx: CGContext?, opacity: Double) {
        let renderer = RenderUtils.createNodeRenderer(pattern.content, view: view, animationCache: animationCache)
        let tileImage = renderer.renderToImage(bounds: pattern.bounds, inset: 0)!
        ctx!.clip()
        ctx?.draw(tileImage.cgImage!, in: pattern.bounds.toCG(), byTiling: true)
    }

    fileprivate func drawGradient(_ gradient: Gradient, ctx: CGContext?, opacity: Double) {
        ctx!.saveGState()
        var colors: [CGColor] = []
        var stops: [CGFloat] = []
        for stop in gradient.stops {
            stops.append(CGFloat(stop.offset))
            let color = RenderUtils.applyOpacity(stop.color, opacity: opacity)
            colors.append(color.toCG())
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

extension Stroke {
    func strokeUsingAlphaOnly() -> Stroke {
        return Stroke(fill: fill.fillUsingAlphaOnly(), width: width, cap: cap, join: join, dashes: dashes, offset: offset)
    }
}

extension Fill {
    func fillUsingAlphaOnly() -> Fill {
        if let color = self as? Color {
            return color.colorUsingAlphaOnly()
        }
        let gradient = self as! Gradient
        let newStops = gradient.stops.map { Stop(offset: $0.offset, color: $0.color.colorUsingAlphaOnly()) }
        if let radial = self as? RadialGradient {
            return RadialGradient(cx: radial.cx, cy: radial.cy, fx: radial.fx, fy: radial.fy, r: radial.r, userSpace: radial.userSpace, stops: newStops)
        }
        let linear = self as! LinearGradient
        return LinearGradient(x1: linear.x1, y1: linear.y1, x2: linear.x2, y2: linear.y2, userSpace: linear.userSpace, stops: newStops)
    }
}

extension Color {
    func colorUsingAlphaOnly() -> Color {
        return Color.black.with(a: Double(a()) / 255.0)
    }
}
