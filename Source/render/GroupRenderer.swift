import Foundation
import UIKit
import RxSwift

class GroupRenderer: NodeRenderer {

	let group: Group

	private var renderers: [NodeRenderer] = []

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

	override func doRender(force: Bool, opacity: Double) {
		renderers.forEach { renderer in
			CGContextSaveGState(ctx.cgContext)
			CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(renderer.node().place))
			setClip(renderer.node())
			renderer.render(force, opacity: renderer.node().opacity * opacity)
			CGContextRestoreGState(ctx.cgContext)
		}
	}

	override func detectTouches(location: CGPoint) -> [Shape] {
		var touchedShapes = [Shape]()
		renderers.forEach { renderer in
			if let inverted = renderer.node().place.invert() {
				CGContextSaveGState(ctx.cgContext)
				CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(renderer.node().place))
				let translatedLocation = CGPointApplyAffineTransform(location, RenderUtils.mapTransform(inverted))
				setClip(renderer.node())
				let offsetLocation = CGPoint(x: translatedLocation.x, y: translatedLocation.y)
				touchedShapes.appendContentsOf(renderer.detectTouches(offsetLocation))
				CGContextRestoreGState(ctx.cgContext)
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
	func setClip(node: Node) {
		if let rect = node.clip as? Rect {
			CGContextClipToRect(ctx.cgContext, CGRect(x: rect.x, y: rect.y, width: rect.w, height: rect.h))
		}
	}

	private func updateRenderers() {
		var nodeToRenderer: [Node: NodeRenderer] = [:]
		for renderer in renderers {
			nodeToRenderer[renderer.node()] = renderer
		}
		self.renderers = []
		for node in group.contents {
			if let renderer = nodeToRenderer.removeValueForKey(node) {
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
