import Foundation

#if os(iOS)
import UIKit
#endif

class GroupRenderer: NodeRenderer {

    weak var group: Group?
    var renderers: [NodeRenderer] = []

    init(group: Group, view: MacawView?, animationCache: AnimationCache?) {
        self.group = group
        super.init(node: group, view: view, animationCache: animationCache)
        updateRenderers()
    }

    deinit {
        dispose()
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

    override func doRender(in context: CGContext, force: Bool, opacity: Double, coloringMode: ColoringMode = .rgb) {
        renderers.forEach { renderer in
            renderer.render(in: context, force: force, opacity: opacity, coloringMode: coloringMode)
        }
    }

    override func doFindNodeAt(path: NodePath, ctx: CGContext) -> NodePath? {
        for renderer in renderers.reversed() {
            if let result = renderer.findNodeAt(parentNodePath: path, ctx: ctx) {
                return result
            }
        }
        return .none
    }

    override func dispose() {
        super.dispose()
        renderers.forEach { renderer in renderer.dispose() }
        renderers.removeAll()
    }

    private func updateRenderers() {
        renderers.forEach { $0.dispose() }
        renderers.removeAll()

        if let updatedRenderers = group?.contents.compactMap ({ child -> NodeRenderer? in
            let childRenderer = RenderUtils.createNodeRenderer(child, view: view, animationCache: animationCache)
            childRenderer.parentRenderer = self
            return childRenderer
        }) {
            renderers = updatedRenderers
        }

        var parent: NodeRenderer = self
        while let parentRenderer = parent.parentRenderer {
            parent = parentRenderer
        }
        parent.calculateZPositionRecursively()
    }

    override func replaceNode(with replacementNode: Node) {
        super.replaceNode(with: replacementNode)

        if let node = replacementNode as? Group {
            group = node
        }
    }
}
