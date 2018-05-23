import Foundation

#if os(iOS)
import UIKit
#endif

struct RenderingInterval {
    let from: Int
    let to: Int
}

class NodeRenderer {

    fileprivate let onNodeChange: () -> Void
    fileprivate let disposables = GroupDisposable()
    fileprivate var active = false
    weak var animationCache: AnimationCache?

    init(node: Node, animationCache: AnimationCache?) {
        self.animationCache = animationCache

        onNodeChange = {
            guard let isAnimating = animationCache?.isAnimating(node) else {
                return
            }

            if isAnimating {
                return
            }
        }

        addObservers()
    }

    func doAddObservers() {
        guard let node = node() else {
            return
        }

        observe(node.placeVar)
        observe(node.opaqueVar)
        observe(node.opacityVar)
        observe(node.clipVar)
        observe(node.effectVar)
    }

    func observe<E>(_ v: Variable<E>) {
        let disposable = v.onChange { [weak self] _ in
            self?.onNodeChange()
        }

        addDisposable(disposable)
    }

    func addDisposable(_ disposable: Disposable) {
        disposable.addTo(disposables)
    }

    open func dispose() {
        removeObservers()
    }

    open func node() -> Node? {
        fatalError("Unsupported")
    }

    final public func render(in context: CGContext, force: Bool, opacity: Double, useAlphaOnly: Bool = false) {
        context.saveGState()
        defer {
            context.restoreGState()
        }
        guard let node = node() else {
            return
        }
        let newOpacity = node.opacity * opacity

        context.concatenate(node.place.toCG())
        applyClip(in: context)

        // no effects, just draw as usual
        guard let effect = node.effect else {
            directRender(in: context, force: force, opacity: newOpacity, useAlphaOnly: useAlphaOnly)
            return
        }

        var effects = [Effect]()
        var next: Effect? = effect
        while next != nil {
            effects.append(next!)
            next = next?.input
        }

        let offset = effects.first { $0 is OffsetEffect } as? OffsetEffect
        let otherEffects = effects.filter { !($0 is OffsetEffect) }
        let useAlphaOnly = otherEffects.contains { effect -> Bool in
            effect is AlphaEffect
        }

        // move to offset
        let move = Transform(m11: 1, m12: 0, m21: 0, m22: 1, dx: offset?.dx ?? 0, dy: offset?.dy ?? 0)
        context.concatenate(move.toCG())

        if otherEffects.isEmpty {
            // just draw offset shape
            directRender(in: context, force: force, opacity: newOpacity, useAlphaOnly: useAlphaOnly)
        } else {
            // apply other effects to offset shape and draw it
            applyEffects(otherEffects, context: context, opacity: opacity, useAlphaOnly: useAlphaOnly)
        }

        // move back and draw the shape itself
        context.concatenate(move.invert()!.toCG())
        directRender(in: context, force: force, opacity: newOpacity)
    }

    final func directRender(in context: CGContext, force: Bool = true, opacity: Double = 1.0, useAlphaOnly: Bool = false) {
        guard let node = node() else {
            return
        }

        if let isAnimating = animationCache?.isAnimating(node), isAnimating {
            self.removeObservers()
            if !force {
                return
            }
        } else {
            self.addObservers()
        }
        doRender(in: context, force: force, opacity: opacity, useAlphaOnly: useAlphaOnly)
    }

    fileprivate func applyEffects(_ effects: [Effect], context: CGContext, opacity: Double, useAlphaOnly: Bool = false) {
        guard let node = node() else {
            return
        }
        for effect in effects {
            if let blur = effect as? GaussianBlur {
                guard let bounds = node.bounds() else {
                    return
                }
                let shadowInset = min(blur.radius * 6 + 1, 150)
                guard let shapeImage = renderToImage(bounds: bounds, inset: shadowInset, useAlphaOnly: useAlphaOnly)?.cgImage else {
                    return
                }
                guard let filteredImage = applyBlur(shapeImage, blur: blur) else {
                    return
                }
                context.draw(filteredImage, in: CGRect(x: bounds.x - shadowInset / 2, y: bounds.y - shadowInset / 2, width: bounds.w + shadowInset, height: bounds.h + shadowInset))
            }
        }
    }

    fileprivate func applyBlur(_ image: CGImage, blur: GaussianBlur) -> CGImage? {
        let image = CIImage(cgImage: image)
        guard let filter = CIFilter(name: "CIGaussianBlur") else {
            return .none
        }
        filter.setDefaults()
        filter.setValue(Int(blur.radius), forKey: kCIInputRadiusKey)
        filter.setValue(image, forKey: kCIInputImageKey)

        let context = CIContext(options: nil)
        let imageRef = context.createCGImage(filter.outputImage!, from: image.extent)
        return imageRef
    }

    func renderToImage(bounds: Rect, inset: Double, useAlphaOnly: Bool = false) -> UIImage? {
        MGraphicsBeginImageContextWithOptions(CGSize(width: bounds.w + inset, height: bounds.h + inset), false, 1)

        guard let tempContext = MGraphicsGetCurrentContext() else {
            return .none
        }

        // flip y-axis and leave space for the blur
        tempContext.translateBy(x: CGFloat(inset / 2 - bounds.x), y: CGFloat(bounds.h + inset / 2 + bounds.y))
        tempContext.scaleBy(x: 1, y: -1)
        directRender(in: tempContext, force: false, opacity: 1.0, useAlphaOnly: useAlphaOnly)

        let img = MGraphicsGetImageFromCurrentImageContext()
        MGraphicsEndImageContext()
        return img
    }

    func doRender(in context: CGContext, force: Bool, opacity: Double, useAlphaOnly: Bool = false) {
        fatalError("Unsupported")
    }

    public final func findNodeAt(location: CGPoint, ctx: CGContext) -> Node? {
        guard let node = node() else {
            return .none
        }

        if node.opaque {
            let place = node.place
            if let inverted = place.invert() {
                ctx.saveGState()
                defer {
                    ctx.restoreGState()
                }

                ctx.concatenate(place.toCG())
                applyClip(in: ctx)
                let loc = location.applying(inverted.toCG())
                let result = doFindNodeAt(location: CGPoint(x: loc.x, y: loc.y), ctx: ctx)
                return result
            }
        }
        return nil
    }

    public func doFindNodeAt(location: CGPoint, ctx: CGContext) -> Node? {
        return nil
    }

    private func applyClip(in context: CGContext) {
        guard let node = node() else {
            return
        }

        guard let clip = node.clip else {
            return
        }

        MGraphicsPushContext(context)
        defer {
            MGraphicsPopContext()
        }

        if let rect = clip as? Rect {
            context.clip(to: CGRect(x: rect.x, y: rect.y, width: rect.w, height: rect.h))
            return
        }

        RenderUtils.toBezierPath(clip).addClip()
    }

    private func addObservers() {
        if !active {
            active = true
            doAddObservers()
        }
    }

    fileprivate func removeObservers() {
        if active {
            active = false
            disposables.dispose()
        }
    }
}
