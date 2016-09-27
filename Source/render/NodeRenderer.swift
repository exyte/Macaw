import Foundation
import UIKit
import RxSwift

class NodeRenderer {

	let ctx: RenderContext

	private let onNodeChange: (Any) -> Void
	private let disposables = GroupDisposable()
	private var active = false
	let animationCache: AnimationCache

	init(node: Node, ctx: RenderContext, animationCache: AnimationCache) {
		self.ctx = ctx
		self.animationCache = animationCache
		onNodeChange = { (_: Any) in ctx.view?.setNeedsDisplay() }
		addObservers()
	}

	func doAddObservers() {
		observe(node().placeVar)
		observe(node().opaqueVar)
		observe(node().opacityVar)
		observe(node().clipVar)
		observe(node().effectVar)
	}

	func observe<E>(variable: Variable<E>) {
		observe(variable.asObservable())
	}

	func observe<E>(observable: Observable<E>) {
		addDisposable(observable.subscribeNext(onNodeChange))
	}

	func addDisposable(disposable: Disposable) {
		disposable.addTo(disposables)
	}

	public func dispose() {
		removeObservers()
	}

	public func node() -> Node {
		fatalError("Unsupported")
	}

    final public func render(force: Bool, opacity: Double) {
        CGContextSaveGState(ctx.cgContext!)
        CGContextConcatCTM(ctx.cgContext!, RenderUtils.mapTransform(node().place))
        applyClip()
        directRender(force, opacity: node().opacity * opacity)
        CGContextRestoreGState(ctx.cgContext!)
    }

	final func directRender(force: Bool = true, opacity: Double = 1.0) {
		if animationCache.isAnimating(node()) {
			self.removeObservers()
			if (!force) {
				return
			}
		} else {
			self.addObservers()
		}
		doRender(force, opacity: opacity)
	}

	func doRender(force: Bool, opacity: Double) {
		fatalError("Unsupported")
	}

    public final func findNodeAt(location: CGPoint) -> Node? {
        if (node().opaque) {
            let place = node().place
            if let inverted = place.invert() {
                CGContextSaveGState(ctx.cgContext!)
                CGContextConcatCTM(ctx.cgContext!, RenderUtils.mapTransform(place))
                applyClip()
                let loc = CGPointApplyAffineTransform(location, RenderUtils.mapTransform(inverted))
                let result = doFindNodeAt(CGPoint(x: loc.x, y: loc.y))
                CGContextRestoreGState(ctx.cgContext!)
                return result
            }
        }
        return nil
    }

    public func doFindNodeAt(location: CGPoint) -> Node? {
        return nil
    }

    private func applyClip() {
        let clip = node().clip
        if let rect = clip as? Rect {
            CGContextClipToRect(ctx.cgContext!, CGRect(x: rect.x, y: rect.y, width: rect.w, height: rect.h))
        } else if clip != nil {
            RenderUtils.toBezierPath(clip!).addClip()
        }
    }

	private func addObservers() {
		if (!active) {
			active = true
			doAddObservers()
		}
	}

	private func removeObservers() {
		if (active) {
			active = false
			disposables.dispose()
		}
	}

}