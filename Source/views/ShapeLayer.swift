import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

public class ShapeLayer: CAShapeLayer {
    public weak var node: Node?
    public var renderingInterval: RenderingInterval?
    public var renderTransform: CGAffineTransform?
    public weak var animationCache: AnimationCache?
    public var shouldRenderContent = true
    public var isForceRenderingEnabled = true

    public override func draw(in ctx: CGContext) {
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
