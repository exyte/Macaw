import UIKit

class ShapeLayer: CALayer {
	var shape: Group?

	override func drawInContext(ctx: CGContext) {
		guard let shape = shape else {
			return
		}

		let renderContext = RenderContext(view: .None)
		renderContext.cgContext = ctx
		GroupRenderer(group: shape, ctx: renderContext, inBounds: false).render()
	}
}