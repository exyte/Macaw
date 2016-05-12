import Foundation
import UIKit

class  GroupRenderer: NodeRenderer {
	var ctx: RenderContext
	var node: Node {
		get { return group }
	}
	let group: Group
	let renderInBounds: Bool

	init(group: Group, ctx: RenderContext, inBounds: Bool = false) {
		self.group = group
		self.ctx = ctx
		self.renderInBounds = inBounds
		hook()
	}

	func hook() {
		func onGroupChange(old: [Node], new: [Node]) {
			ctx.view?.setNeedsDisplay()
		}
		group.contentsProperty.addListener(onGroupChange)
	}

	func render() {
		let staticContents = group.contents.filter { !$0.animating }
		let contentRenderers = staticContents.map { RenderUtils.createNodeRenderer($0, context: ctx) }
		contentRenderers.forEach { renderer in
			if let rendererVal = renderer {
				CGContextSaveGState(ctx.cgContext)
				if !renderInBounds {
					CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(rendererVal.node.pos))
				}

				setClip(rendererVal.node)
				rendererVal.render()
				CGContextRestoreGState(ctx.cgContext)
			}
		}
	}

	// TODO: extract to NodeRenderer
	// TODO: path support
	func setClip(node: Node) {
		if let rect = node.clip as? Rect {
			CGContextClipToRect(ctx.cgContext, CGRect(x: rect.x, y: rect.y, width: rect.w, height: rect.h))
		}
	}
}
