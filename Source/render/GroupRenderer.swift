import Foundation
import UIKit

class GroupRenderer: NodeRenderer {

    weak var group: Group?

    fileprivate var renderers: [NodeRenderer] = []

    init(group: Group, ctx: RenderContext, animationCache: AnimationCache) {
        self.group = group
        super.init(node: group, ctx: ctx, animationCache: animationCache)
        updateRenderers()
    }

    override func doAddObservers() {
        super.doAddObservers()
        
        guard let group = group else {
            return
        }
        
        group.contentsVar.onChange { [weak self] _ in
            self?.updateRenderers()
        }
         observe(group.contentsVar)
    }

    override func node() -> Node? {
        return group
    }

    override func doRender(_ force: Bool, opacity: Double) {
        renderers.forEach { renderer in
            renderer.render(force: force, opacity: opacity)
        }
    }

    override func doFindNodeAt(location: CGPoint, ctx: CGContext) -> Node? {
        for renderer in renderers.reversed() {
            if let node = renderer.findNodeAt(location: location, ctx: ctx) {
                return node
            }
        }
        return nil
    }

    override func dispose() {
        super.dispose()
        renderers.forEach { renderer in renderer.dispose() }
        renderers = []
    }

    private func updateRenderers() {
        renderers.forEach{ $0.dispose() }
        renderers.removeAll()
        
        if let updatedRenderers =  group?.contents.map ({ RenderUtils.createNodeRenderer($0, context: ctx, animationCache: animationCache) }) {
            renderers = updatedRenderers
        }
    }
}
