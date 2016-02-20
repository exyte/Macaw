import Foundation
import UIKit

class GroupRenderer: NodeRenderer {
    var ctx: RenderContext
    let group: Group
    
    let contentRenderers: [NodeRenderer?]
    
    init(group: Group, ctx: RenderContext) {
        self.group = group
        self.ctx = ctx
        self.contentRenderers = group.contents.map { RenderUtils.createNodeRenderer($0, context: ctx) }
    }
    
    func render() {
        CGContextSaveGState(ctx.cgContext)
        CGContextConcatCTM(ctx.cgContext, RenderUtils.mapTransform(group.pos))
        
        contentRenderers.forEach { renderer in
            if let rendererVal = renderer {
                rendererVal.render()
            }
        }
        CGContextRestoreGState(ctx.cgContext)

    }
}
