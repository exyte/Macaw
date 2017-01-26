import UIKit

class ShapeLayer: CAShapeLayer {
	var node: Node?
	var renderTransform: CGAffineTransform?
	var animationCache: AnimationCache?
    var shouldRenderContent = true

	override func draw(in ctx: CGContext) {
        if !shouldRenderContent {
            super.draw(in: ctx)
            return
        }
        
		guard let node = node else {
			return
		}

		guard let animationCache = animationCache else {
			return
		}

		let renderContext = RenderContext(view: .none)
		renderContext.cgContext = ctx

		if let renderTransform = renderTransform {
			ctx.concatenate(renderTransform)
		}

		let renderer = RenderUtils.createNodeRenderer(node, context: renderContext, animationCache: animationCache)
		renderer.directRender()
		renderer.dispose()
	}
}
