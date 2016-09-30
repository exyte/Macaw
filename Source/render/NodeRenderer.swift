import Foundation
import UIKit
import RxSwift

class NodeRenderer {

	let ctx: RenderContext

	fileprivate let onNodeChange: (Any) -> Void
	fileprivate let disposables = GroupDisposable()
	fileprivate var active = false
	let animationCache: AnimationCache

	init(node: Node, ctx: RenderContext, animationCache: AnimationCache) {
		self.ctx = ctx
		self.animationCache = animationCache
		onNodeChange = { (_: Any) in ctx.view?.setNeedsDisplay() }
		addObservers()
	}

	func doAddObservers() {
		observeAnimatable(node().placeVar)
		observe(node().opaqueVar)
		observeAnimatable(node().opacityVar)
		observe(node().clipVar)
		observe(node().effectVar)
	}

	func observeAnimatable<E>(_ variable: AnimatableVariable<E>) {
		observe(variable.asObservable())
	}
    
    func observe<E>(_ variable: Variable<E>) {
        observe(variable.asObservable())
    }

	func observe<E>(_ observable: Observable<E>) {
		addDisposable(observable.subscribe(onNext: onNodeChange))
	}

	func addDisposable(_ disposable: Disposable) {
		disposable.addTo(disposables)
	}

	open func dispose() {
		removeObservers()
	}

	open func node() -> Node {
		fatalError("Unsupported")
	}

    final public func render(force: Bool, opacity: Double) {
        ctx.cgContext!.saveGState()
        ctx.cgContext!.concatenate(RenderUtils.mapTransform(node().place))
        applyClip()
        directRender(force: force, opacity: node().opacity * opacity)
        ctx.cgContext!.restoreGState()
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

	func doRender(_ force: Bool, opacity: Double) {
		fatalError("Unsupported")
	}

    public final func findNodeAt(location: CGPoint) -> Node? {
        if (node().opaque) {
            let place = node().place
            if let inverted = place.invert() {
                ctx.cgContext!.saveGState()
                ctx.cgContext!.concatenate(RenderUtils.mapTransform(place))
                applyClip()
                let loc = location.applying(RenderUtils.mapTransform(inverted))
                let result = doFindNodeAt(location: CGPoint(x: loc.x, y: loc.y))
                ctx.cgContext!.restoreGState()
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
            ctx.cgContext!.clip(to: CGRect(x: rect.x, y: rect.y, width: rect.w, height: rect.h))
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

	fileprivate func removeObservers() {
		if (active) {
			active = false
			disposables.dispose()
		}
	}

}
