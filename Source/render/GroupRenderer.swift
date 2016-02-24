import Foundation
import UIKit

class GroupRenderer: NodeRenderer {
    var ctx: RenderContext
    var node: Node {
        get { return group }
    }
    let group: Group
    
    let contentRenderers: [NodeRenderer?]
    
    init(group: Group, ctx: RenderContext) {
        self.group = group
        self.ctx = ctx
        self.contentRenderers = group.contents.map { RenderUtils.createNodeRenderer($0, context: ctx) }
    }
    
    func render() {
        contentRenderers.forEach { renderer in
            if let rendererVal = renderer {
                CGContextSaveGState(ctx.cgContext)
                CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(rendererVal.node.pos))
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
