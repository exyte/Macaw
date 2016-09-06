import Foundation
import UIKit
import RxSwift

class GroupRenderer: NodeRenderer {

	var animationCache: AnimationCache

	let group: Group

	init(group: Group, ctx: RenderContext, animationCache: AnimationCache) {
		self.group = group
		self.animationCache = animationCache
		super.init(node: group, ctx: ctx)
	}

	override func addObservers() {
		super.addObservers()
		observe(group.contents.rx_elements())
	}

	override func node() -> Node {
		return group
	}

	override func render(force: Bool, opacity: Double) {

		if !force {

			// Cutting animated content
			if animationCache.isAnimating(group) {
				return
			}
		}

		let staticContents = group.contents.filter { !animationCache.isAnimating($0) }

		let contentRenderers = staticContents.map { RenderUtils.createNodeRenderer($0, context: ctx, animationCache: animationCache) }

		contentRenderers.forEach { renderer in
			CGContextSaveGState(ctx.cgContext)
			CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(renderer.node().place))
			setClip(renderer.node())
			renderer.render(force, opacity: renderer.node().opacity * opacity)
			CGContextRestoreGState(ctx.cgContext)
		}
	}

	override func detectTouches(location: CGPoint) -> [Shape] {
		var touchedShapes = [Shape]()
		let staticContents = group.contents.filter { !animationCache.isAnimating($0) }

		let contentRenderers = staticContents.map { RenderUtils.createNodeRenderer($0, context: ctx, animationCache: animationCache) }

		contentRenderers.forEach { renderer in
			if let inverted = renderer.node().place.invert() {
				CGContextSaveGState(ctx.cgContext)
				CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(renderer.node().place))
				let translatedLocation = CGPointApplyAffineTransform(location, RenderUtils.mapTransform(inverted))
				setClip(renderer.node())
				let offsetLocation = CGPoint(x: translatedLocation.x, y: translatedLocation.y)
				touchedShapes.appendContentsOf(renderer.detectTouches(offsetLocation))
				CGContextRestoreGState(ctx.cgContext)
			}
			renderer.dispose()
		}

		return touchedShapes
	}

	// TODO: extract to NodeRenderer
	// TODO: path support
	func setClip(node: Node) {
		if let rect = node.clip as? Rect {
			CGContextClipToRect(ctx.cgContext, CGRect(x: rect.x, y: rect.y, width: rect.w, height: rect.h))
		}
	}
}
