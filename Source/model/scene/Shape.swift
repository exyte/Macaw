#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

open class Shape: Node {

    public let formVar: AnimatableVariable<Locus>
    open var form: Locus {
        get { return formVar.value }
        set(val) { formVar.value = val }
    }

    public let fillVar: AnimatableVariable<Fill?>
    open var fill: Fill? {
        get { return fillVar.value }
        set(val) { fillVar.value = val }
    }

    public let strokeVar: AnimatableVariable<Stroke?>
    open var stroke: Stroke? {
        get { return strokeVar.value }
        set(val) { strokeVar.value = val }
    }

    public init(form: Locus, fill: Fill? = nil, stroke: Stroke? = nil, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, mask: Node? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
        self.formVar = AnimatableVariable<Locus>(form)
        self.fillVar = AnimatableVariable<Fill?>(fill)
        self.strokeVar = AnimatableVariable<Stroke?>(stroke)
        super.init(
            place: place,
            opaque: opaque,
            opacity: opacity,
            clip: clip,
            mask: mask,
            effect: effect,
            visible: visible,
            tag: tag
        )

        self.formVar.node = self
        self.strokeVar.node = self
        self.fillVar.node = self
    }

    override open var bounds: Rect? {
        guard let ctx = createContext() else {
            return .none
        }

        var shouldStrokePath = false

        if let stroke = stroke {
            RenderUtils.setStrokeAttributes(stroke, ctx: ctx)
            shouldStrokePath = true
        }

        RenderUtils.setGeometry(self.form, ctx: ctx)

        let point = ctx.currentPointOfPath

        if shouldStrokePath {
            ctx.replacePathWithStrokedPath()
        }

        var rect = ctx.boundingBoxOfPath

        if rect.height == 0,
            rect.width == 0 && (rect.origin.x == CGFloat.infinity || rect.origin.y == CGFloat.infinity) {

            rect.origin = point
        }

        endContext()

        return rect.toMacaw()
    }

    fileprivate func createContext() -> CGContext? {

        let smallSize = CGSize(width: 1.0, height: 1.0)

        MGraphicsBeginImageContextWithOptions(smallSize, false, 1.0)

        return MGraphicsGetCurrentContext()
    }

    fileprivate func endContext() {
        MGraphicsEndImageContext()
    }
}
