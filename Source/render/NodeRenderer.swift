import Foundation

#if os(iOS)
import UIKit
#endif

struct RenderingInterval {
    let from: Int
    let to: Int
}

class NodeRenderer {

    let ctx: RenderContext

    fileprivate let onNodeChange: () -> Void
    fileprivate let disposables = GroupDisposable()
    fileprivate var active = false
    weak var animationCache: AnimationCache?

    init(node: Node, ctx: RenderContext, animationCache: AnimationCache?) {
        self.ctx = ctx
        self.animationCache = animationCache

        onNodeChange = {
            guard let isAnimating = animationCache?.isAnimating(node) else {
                return
            }

            if isAnimating {
                return
            }

            ctx.view?.setNeedsDisplay()
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

    final public func render(force: Bool, opacity: Double) {
        ctx.cgContext!.saveGState()
        defer {
            ctx.cgContext!.restoreGState()
        }

        guard let node = node() else {
            return
        }

        ctx.cgContext!.concatenate(node.place.toCG())
        applyClip()
        directRender(force: force, opacity: node.opacity * opacity)
    }

    final func directRender(force: Bool = true, opacity: Double = 1.0) {
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
        doRender(force, opacity: opacity)
    }

    func doRender(_ force: Bool, opacity: Double) {
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
                applyClip()
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

    private func applyClip() {
        guard let node = node() else {
            return
        }

        guard let clip = node.clip, let context = ctx.cgContext else {
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
