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

	public func detectTouches(location: CGPoint) -> [Shape] {
		return []
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