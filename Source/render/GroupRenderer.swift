import Foundation
import UIKit
import RxSwift

class GroupRenderer: NodeRenderer {
	var ctx: RenderContext
	var node: Node {
		get { return group }
	}

	var animationCache: AnimationCache

	let group: Group
	let disposeBag = DisposeBag()

	init(group: Group, ctx: RenderContext, animationCache: AnimationCache) {
		self.group = group
		self.ctx = ctx
		self.animationCache = animationCache

		hook()
	}

	func hook() {
		func onGroupChange(new: [Node]) {
			ctx.view?.setNeedsDisplay()
		}

		group.contents.rx_elements().subscribeNext { new in
			onGroupChange(new)
		}.addDisposableTo(disposeBag)
	}

	func render(force: Bool, opacity: Double) {

		if !force {

			// Cutting animated content
			if animationCache.isAnimating(group) {
				return
			}
		}

		let staticContents = group.contents.filter { !animationCache.isAnimating($0) }

		let contentRenderers = staticContents.map { RenderUtils.createNodeRenderer($0, context: ctx, animationCache: animationCache) }
        
        CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(self.node.place))
        
		contentRenderers.forEach { renderer in
			CGContextSaveGState(ctx.cgContext)
            if !(renderer.node is Group) {
                CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(renderer.node.place))
            }
			setClip(renderer.node)
			renderer.render(force, opacity: renderer.node.opacity * opacity)
			CGContextRestoreGState(ctx.cgContext)
		}
	}

	func detectTouches(location: CGPoint) -> [Shape] {
		var touchedShapes = [Shape]()
		let staticContents = group.contents.filter { !animationCache.isAnimating($0) }

		let contentRenderers = staticContents.map { RenderUtils.createNodeRenderer($0, context: ctx, animationCache: animationCache) }

		contentRenderers.forEach { renderer in
			if let inverted = renderer.node.place.invert() {
				CGContextSaveGState(ctx.cgContext)
				CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(renderer.node.place))
				let translatedLocation = CGPointApplyAffineTransform(location, RenderUtils.mapTransform(inverted))
				setClip(renderer.node)
				let offsetLocation = CGPoint(x: translatedLocation.x, y: translatedLocation.y)
				touchedShapes.appendContentsOf(renderer.detectTouches(offsetLocation))
				CGContextRestoreGState(ctx.cgContext)
			}
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
