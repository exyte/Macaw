import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class ShapeLayer: CAShapeLayer {
    weak var node: Node?
    var renderingInterval: RenderingInterval?
    var renderTransform: CGAffineTransform?
    weak var animationCache: AnimationCache?
    var shouldRenderContent = true
    var isForceRenderingEnabled = true

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

        let renderer = RenderUtils.createNodeRenderer(node, context: renderContext, animationCache: animationCache, interval: renderingInterval)
        renderer.directRender(force: isForceRenderingEnabled)
        renderer.dispose()
    }
}
