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
                rendererVal.render()
                CGContextRestoreGState(ctx.cgContext)
            }
        }
    }
}
