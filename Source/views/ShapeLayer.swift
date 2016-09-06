import UIKit

class ShapeLayer: CAShapeLayer {
	var node: Node?
	var renderTransform: CGAffineTransform?
	var animationCache: AnimationCache?

	override func drawInContext(ctx: CGContext) {
		guard let node = node else {
			return
		}

		guard let animationCache = animationCache else {
			return
		}

		let renderContext = RenderContext(view: .None)
		renderContext.cgContext = ctx

		if let renderTransform = renderTransform {
			CGContextConcatCTM(ctx, renderTransform)
		}

		let renderer = RenderUtils.createNodeRenderer(node, context: renderContext, animationCache: animationCache)
		renderer.render(true, opacity: 1.0)
		renderer.dispose()
	}
}