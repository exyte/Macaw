import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

class ShapeLayer: CAShapeLayer {
    weak var renderer: NodeRenderer?
    var shouldRenderContent = true
    var isForceRenderingEnabled = true

    override func draw(in ctx: CGContext) {
        if !shouldRenderContent {
            super.draw(in: ctx)
            return
        }

        let renderContext = RenderContext(view: .none)
        renderContext.cgContext = ctx

        renderer?.directRender(in: ctx, force: isForceRenderingEnabled)
    }
}
