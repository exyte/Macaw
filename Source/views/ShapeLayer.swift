import UIKit

class ShapeLayer: CAShapeLayer {
	var node: Node?
	var renderTransform: CGAffineTransform?

	override func drawInContext(ctx: CGContext) {
		guard let node = node else {
			return
		}

		let renderContext = RenderContext(view: .None)
		renderContext.cgContext = ctx

		if let renderTransform = renderTransform {
			CGContextConcatCTM(ctx, renderTransform)
		}

		let renderer = RenderUtils.createNodeRenderer(node, context: renderContext)
		renderer.render(true, opacity: 1.0)
	}
}