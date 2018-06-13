#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

open class Shape: Node {

    open let formVar: AnimatableVariable<Locus>
    open var form: Locus {
        get { return formVar.value }
        set(val) { formVar.value = val }
    }

    open let fillVar: AnimatableVariable<Fill?>
    open var fill: Fill? {
        get { return fillVar.value }
        set(val) { fillVar.value = val }
    }

    open let strokeVar: AnimatableVariable<Stroke?>
    open var stroke: Stroke? {
        get { return strokeVar.value }
        set(val) { strokeVar.value = val }
    }

    public init(form: Locus, fill: Fill? = nil, stroke: Stroke? = nil, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
        self.formVar = AnimatableVariable<Locus>(form)
        self.fillVar = AnimatableVariable<Fill?>(fill)
        self.strokeVar = AnimatableVariable<Stroke?>(stroke)
        super.init(
            place: place,
            opaque: opaque,
            opacity: opacity,
            clip: clip,
            effect: effect,
            visible: visible,
            tag: tag
        )

        self.formVar.node = self
        self.strokeVar.node = self
        self.fillVar.node = self
    }

    override open func bounds() -> Rect {
        guard let ctx = createContext() else {
            return .zero()
        }

        let path = RenderUtils.toCGPath(self.form)

        ctx.addPath(path)
        if let stroke = stroke {
            ctx.setLineWidth(CGFloat(stroke.width))
            ctx.setLineCap(stroke.cap.toCG())
            ctx.setLineJoin(stroke.join.toCG())
            ctx.setMiterLimit(CGFloat(stroke.miterLimit))
            if !stroke.dashes.isEmpty {
                ctx.setLineDash(phase: CGFloat(stroke.offset),
                                lengths: stroke.dashes.map { CGFloat($0) })
            }

            ctx.replacePathWithStrokedPath()
        }

        let rect = ctx.boundingBoxOfPath

        endContext()

        return rect.toMacaw()
    }
}
