import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class ShapeRenderer: NodeRenderer {

    var shape: Shape

    init(shape: Shape, view: DrawingView?, parentRenderer: GroupRenderer? = nil) {
        self.shape = shape
        super.init(node: shape, view: view, parentRenderer: parentRenderer)
    }

    deinit {
        dispose()
    }

    override var node: Node {
        return shape
    }

    override func doAddObservers() {
        super.doAddObservers()

        observe(shape.formVar)
        observe(shape.fillVar)
        observe(shape.strokeVar)
    }

    override func doRender(in context: CGContext, force: Bool, opacity: Double, coloringMode: ColoringMode = .rgb) {
        if shape.fill == nil && shape.stroke == nil {
            return
        }

        RenderUtils.setGeometry(shape.form, ctx: context)

        var fillRule = FillRule.nonzero
        if let path = shape.form as? Path {
            fillRule = path.fillRule
        }

        switch coloringMode {
        case .rgb:
            drawPath(fill: shape.fill, stroke: shape.stroke, ctx: context, opacity: opacity, fillRule: fillRule)
        case .greyscale:
            drawPath(fill: shape.fill?.fillUsingGrayscaleNoAlpha(), stroke: shape.stroke?.strokeUsingGrayscaleNoAlpha(), ctx: context, opacity: opacity, fillRule: fillRule)
        case .alphaOnly:
            drawPath(fill: shape.fill?.fillUsingAlphaOnly(), stroke: shape.stroke?.strokeUsingAlphaOnly(), ctx: context, opacity: opacity, fillRule: fillRule)
        }
    }

    override func doFindNodeAt(path: NodePath, ctx: CGContext) -> NodePath? {
        RenderUtils.setGeometry(shape.form, ctx: ctx)
        var drawingMode: CGPathDrawingMode?
        if let stroke = shape.stroke {
            RenderUtils.setStrokeAttributes(stroke, ctx: ctx)
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
            contains = ctx.pathContains(path.location, mode: mode)

            if contains {
                return path
            }
        }

        // Prepare for next figure hittesting - clear current context path
        ctx.beginPath()
        return .none
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
        RenderUtils.setStrokeAttributes(stroke, ctx: ctx)

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
        var patternNode = pattern.content
        if !pattern.userSpace, let node = BoundsUtils.createNodeFromRespectiveCoords(respectiveNode: pattern.content, absoluteLocus: shape.form) {
            patternNode = node
        }
        let renderer = RenderUtils.createNodeRenderer(patternNode, view: view)

        var patternBounds = pattern.bounds
        if !pattern.userSpace {
            let boundsTranform = BoundsUtils.transformForLocusInRespectiveCoords(respectiveLocus: pattern.bounds, absoluteLocus: shape.form)
            patternBounds = pattern.bounds.applying(boundsTranform)
        }
        guard let tileCGImage = renderer.renderToImage(bounds: patternBounds, inset: 0)?.cgImage else {
            return
        }
        ctx?.clip()
        ctx?.draw(tileCGImage, in: patternBounds.toCG(), byTiling: true)
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
    func strokeUsingGrayscaleNoAlpha() -> Stroke {
        return Stroke(fill: fill.fillUsingGrayscaleNoAlpha(), width: width, cap: cap, join: join, dashes: dashes, offset: offset)
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

    func fillUsingGrayscaleNoAlpha() -> Fill {
        if let color = self as? Color {
            return color.toGrayscaleNoAlpha()
        }
        let gradient = self as! Gradient
        let newStops = gradient.stops.map { Stop(offset: $0.offset, color: $0.color.toGrayscaleNoAlpha()) }
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

    func toGrayscaleNoAlpha() -> Color {
        let grey = Int(0.21 * Double(r()) + 0.72 * Double(g()) + 0.07 * Double(b()))
        return Color.rgb(r: grey, g: grey, b: grey)
    }
}
