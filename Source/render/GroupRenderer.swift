import Foundation
import UIKit
import RxSwift

class GroupRenderer: NodeRenderer {
    var ctx: RenderContext
    var node: Node {
        get { return group }
    }
    let group: Group
    let disposeBag = DisposeBag()
    
    init(group: Group, ctx: RenderContext) {
        self.group = group
        self.ctx = ctx
        hook()
    }
    
    func hook() {
        func onGroupChange(new: [Node]) {
            ctx.view.setNeedsDisplay()
        }
        group.contentsVar.asObservable().subscribeNext { new in
            onGroupChange(new)
        }.addDisposableTo(disposeBag)
    }
    
    func render() {
        let contentRenderers = group.contents.map { RenderUtils.createNodeRenderer($0, context: ctx) }
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
