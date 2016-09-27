import Foundation
import UIKit
import RxSwift

class GroupRenderer: NodeRenderer {

	let group: Group

	fileprivate var renderers: [NodeRenderer] = []

	init(group: Group, ctx: RenderContext, animationCache: AnimationCache) {
		self.group = group
		super.init(node: group, ctx: ctx, animationCache: animationCache)
		updateRenderers()
	}

	override func doAddObservers() {
		super.doAddObservers()
		observe(group.contents.rx_elements())
		addDisposable(group.contents.rx_elements().subscribeNext { event in self.updateRenderers() })
	}

	override func node() -> Node {
		return group
	}

	override func doRender(_ force: Bool, opacity: Double) {
		renderers.forEach { renderer in
			ctx.cgContext!.saveGState()
			ctx.cgContext!.concatenate(RenderUtils.mapTransform(renderer.node().place))
			setClip(renderer.node())
			renderer.render(force, opacity: renderer.node().opacity * opacity)
			ctx.cgContext!.restoreGState()
		}
	}

	override func detectTouches(_ location: CGPoint) -> [Shape] {
		var touchedShapes = [Shape]()
		renderers.forEach { renderer in
			if let inverted = renderer.node().place.invert() {
				ctx.cgContext!.saveGState()
				ctx.cgContext!.concatenate(RenderUtils.mapTransform(renderer.node().place))
				let translatedLocation = location.applying(RenderUtils.mapTransform(inverted))
				setClip(renderer.node())
				let offsetLocation = CGPoint(x: translatedLocation.x, y: translatedLocation.y)
				touchedShapes.append(contentsOf: renderer.detectTouches(offsetLocation))
				ctx.cgContext!.restoreGState()
			}
		}

		return touchedShapes
	}

	override func dispose() {
		super.dispose()
		renderers.forEach { renderer in renderer.dispose() }
		renderers = []
	}

	// TODO: extract to NodeRenderer
	// TODO: path support
	func setClip(_ node: Node) {
		if let rect = node.clip as? Rect {
			ctx.cgContext!.clip(to: CGRect(x: rect.x, y: rect.y, width: rect.w, height: rect.h))
		}
	}

	fileprivate func updateRenderers() {
		var nodeToRenderer: [Node: NodeRenderer] = [:]
		for renderer in renderers {
			nodeToRenderer[renderer.node()] = renderer
		}
		self.renderers = []
		for node in group.contents {
			if let renderer = nodeToRenderer.removeValue(forKey: node) {
				self.renderers.append(renderer)
			} else {
				self.renderers.append(RenderUtils.createNodeRenderer(node, context: ctx, animationCache: animationCache))
			}
		}
		for renderer in nodeToRenderer.values {
			renderer.dispose()
		}
	}
}
