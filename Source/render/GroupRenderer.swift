import Foundation
import UIKit

class GroupRenderer: NodeRenderer {

	let group: Group

	fileprivate var renderers: [NodeRenderer] = []

	init(group: Group, ctx: RenderContext, animationCache: AnimationCache) {
		self.group = group
		super.init(node: group, ctx: ctx, animationCache: animationCache)
		updateRenderers()
	}

	override func doAddObservers() {
		super.doAddObservers()
        
        group.contentsVar.onChange { _ in
            self.updateRenderers()
        }
	}

	override func node() -> Node {
		return group
	}

	override func doRender(_ force: Bool, opacity: Double) {
		renderers.forEach { renderer in
			renderer.render(force: force, opacity: opacity)
		}
	}

    override func doFindNodeAt(location: CGPoint) -> Node? {
        for renderer in renderers.reversed() {
            if let node = renderer.findNodeAt(location: location) {
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
		var nodeToRenderer: [Node: NodeRenderer] = [:]
		for renderer in renderers {
			nodeToRenderer[renderer.node()] = renderer
		}
		self.renderers = []
		for node in group.contents {
			if let renderer = nodeToRenderer.removeValue(forKey: node) {
				self.renderers.append(renderer)
			} else {
				self.renderers.append(RenderUtils.createNodeRenderer(node, context: ctx, animationCache: animationCache))
			}
		}
		for renderer in nodeToRenderer.values {
			renderer.dispose()
		}
	}
}
