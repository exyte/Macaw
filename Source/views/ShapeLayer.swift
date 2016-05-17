import UIKit

class ShapeLayer: CAShapeLayer {
	var shape: Group?
	var renderTransform: CGAffineTransform?

	override func drawInContext(ctx: CGContext) {
		guard let shape = shape else {
			return
		}

		let renderContext = RenderContext(view: .None)
		renderContext.cgContext = ctx

		if let renderTransform = renderTransform {
			CGContextConcatCTM(ctx, renderTransform)
		}

		GroupRenderer(group: shape, ctx: renderContext).render()
	}
}