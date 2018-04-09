import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class ShapeRenderer: NodeRenderer {

    weak var shape: Shape?

    init(shape: Shape, ctx: RenderContext, animationCache: AnimationCache?) {
        self.shape = shape
        super.init(node: shape, ctx: ctx, animationCache: animationCache)
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

    override func doRender(_ force: Bool, opacity: Double) {
        guard let shape = shape, let context = ctx.cgContext else { return }
        
        if let blur = shape.effect as? GaussianBlur {
            let shadowInset = min(max(blur.radius * 6, 10), 150) // between 10 and 150
            guard let shapeImage = saveToImage(shape: shape, shadowInset: shadowInset, opacity: opacity)?.cgImage else { return }
            
            guard let filteredImage = applyFilter(shapeImage, blur: blur) else { return }
            
            guard let bounds = shape.bounds() else { return }
            context.draw(filteredImage, in: CGRect(x: bounds.x-shadowInset/2, y: bounds.y-shadowInset/2, width: bounds.w+shadowInset, height: bounds.h+shadowInset))
        }
            
        else if (shape.fill != nil || shape.stroke != nil) {
            setGeometry(shape.form, ctx: context)
            drawPath(shape.fill, stroke: shape.stroke, ctx: context, opacity: opacity)
        }
    }
    
    fileprivate func applyFilter(_ image: CGImage, blur: GaussianBlur) -> CGImage? {
        let image = CIImage(cgImage: image)
        guard let filter = CIFilter(name: "CIGaussianBlur") else { return .none }
        filter.setDefaults()
        filter.setValue(blur.radius, forKey: kCIInputRadiusKey)
        filter.setValue(image, forKey: kCIInputImageKey)
        
        let context = CIContext(options: nil)
        let imageRef = context.createCGImage(filter.outputImage!, from: image.extent)
        return imageRef
    }
    
    fileprivate func saveToImage(shape: Shape, shadowInset: Double, opacity: Double) -> MImage? {
        guard let size = shape.bounds() else { return .none }
        MGraphicsBeginImageContextWithOptions(CGSize(width: size.w+shadowInset, height: size.h+shadowInset), false, 1)
        
        guard let tempContext = MGraphicsGetCurrentContext() else { return .none }
        
        if (shape.fill != nil || shape.stroke != nil) {
            // flip y-axis and leave space for the blur
            tempContext.translateBy(x: CGFloat(shadowInset/2), y: CGFloat(size.h+shadowInset/2))
            tempContext.scaleBy(x: 1, y: -1)
            setGeometry(shape.form, ctx: tempContext)
            drawPath(shape.fill, stroke: shape.stroke, ctx: tempContext, opacity: opacity)
        }
        
        let img = MGraphicsGetImageFromCurrentImageContext()
        MGraphicsEndImageContext()
        return img
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
            ctx.addRect(newCGRect(rect))
        } else if let round = locus as? RoundRect {
            let corners = CGSize(width: CGFloat(round.rx), height: CGFloat(round.ry))
            let path = MBezierPath(roundedRect: newCGRect(round.rect), byRoundingCorners:
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
            ctx.addPath(RenderUtils.toCGPath(locus))
        }
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
