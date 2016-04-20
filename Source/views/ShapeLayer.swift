import UIKit

class ShapeLayer: CALayer {
	var shape: Shape?

	override func drawInContext(ctx: CGContext) {
		guard let shape = shape else {
			return
		}

		let renderContext = RenderContext(view: .None)
		renderContext.cgContext = ctx
		ShapeRenderer(shape: shape, ctx: renderContext).render()
	}
}