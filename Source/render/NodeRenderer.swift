import Foundation
import UIKit
import RxSwift

class NodeRenderer {

	let ctx: RenderContext

	private let onNodeChange: (Any) -> Void
	private let disposables = GroupDisposable()

	init(node: Node, ctx: RenderContext) {
		self.ctx = ctx
		onNodeChange = { (_: Any) in ctx.view?.setNeedsDisplay() }
		addObservers()
	}

	func addObservers() {
		observe(node().placeVar)
		observe(node().opaqueVar)
		observe(node().opacityVar)
		observe(node().clipVar)
		observe(node().effectVar)
	}

	func removeObservers() {
		disposables.dispose()
	}

	func observe<E>(variable: Variable<E>) {
		observe(variable.asObservable())
	}

	func observe<E>(observable: Observable<E>) {
		observable.subscribeNext(onNodeChange).addTo(disposables)
	}

	public func dispose() {
		removeObservers()
	}

	public func node() -> Node {
		fatalError("Unsupported")
	}

	public func render(force: Bool, opacity: Double) {

	}

	public func detectTouches(location: CGPoint) -> [Shape] {
		return []
	}

}