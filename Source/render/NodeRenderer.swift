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
		observe(node().placeVar)
		observe(node().opaqueVar)
		observe(node().opacityVar)
		observe(node().clipVar)
		observe(node().effectVar)
	}

	func observe<E>(_ variable: Variable<E>) {
		observe(variable.asObservable())
	}

	func observe<E>(_ observable: Observable<E>) {
		addDisposable(observable.subscribeNext(onNodeChange))
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

	final public func render(_ force: Bool, opacity: Double) {
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

	open func detectTouches(_ location: CGPoint) -> [Shape] {
		return []
	}

	fileprivate func addObservers() {
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
