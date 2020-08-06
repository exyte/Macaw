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

    init(group: Group, view: DrawingView?, parentRenderer: GroupRenderer? = nil) {
        self.group = group
        super.init(node: group, view: view, parentRenderer: parentRenderer)
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
    }

    override func freeCachedAbsPlace() {
        for renderer in renderers {
            renderer.freeCachedAbsPlace()
        }
    }

    override func doRender(in context: CGContext, force: Bool, opacity: Double, coloringMode: ColoringMode = .rgb) {
        renderers.forEach { renderer in
            if !renderer.isAnimating() {
                renderer.render(in: context, force: force, opacity: opacity, coloringMode: coloringMode)
            }
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
            $0.dispose()
        }
        renderers.removeAll()

        renderers = group.contents.compactMap { child -> NodeRenderer? in
            RenderUtils.createNodeRenderer(child, view: view, parentRenderer: self)
        }

        var parent: NodeRenderer = self
        while let parentRenderer = parent.parentRenderer {
            parent = parentRenderer
        }
        parent.calculateZPositionRecursively()
    }
}
