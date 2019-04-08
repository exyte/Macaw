import Foundation

#if os(iOS)
import UIKit
#endif

class GroupRenderer: NodeRenderer {

    var group: Group
    var renderers: [NodeRenderer] = []

    override var node: Node {
        return group
    }

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

        group.contentsVar.onChange { [weak self] _ in
            self?.updateRenderers()
        }
        observe(group.contentsVar)

        group.placeVar.onChange { [weak self] (_) in
            self?.freeCachedAbsPlace()
        }
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

        renderers.forEach {
            animationCache?.freeLayerHard($0)
            $0.dispose()
        }
        renderers.removeAll()

        renderers = group.contents.compactMap { child -> NodeRenderer? in
            let childRenderer = RenderUtils.createNodeRenderer(child, view: view, animationCache: animationCache)
            childRenderer.parentRenderer = self
            return childRenderer
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
