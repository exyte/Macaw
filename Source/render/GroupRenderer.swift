import Foundation

#if os(iOS)
import UIKit
#endif

class GroupRenderer: NodeRenderer {

    weak var group: Group?

    fileprivate var renderers: [NodeRenderer] = []
    let renderingInterval: RenderingInterval?

    init(group: Group, view: MView?, animationCache: AnimationCache?, interval: RenderingInterval? = .none) {
        self.group = group
        self.renderingInterval = interval
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
        renderers.removeAll()
    }

    private func updateRenderers() {
        renderers.forEach { $0.dispose() }
        renderers.removeAll()

        if let updatedRenderers = group?.contents.compactMap ({ child -> NodeRenderer? in
            guard let interval = renderingInterval else {
                return RenderUtils.createNodeRenderer(child, view: view, animationCache: animationCache)
            }

            let index = AnimationUtils.absoluteIndex(child, useCache: true)
            if index > interval.from && index < interval.to {
                return RenderUtils.createNodeRenderer(child, view: view, animationCache: animationCache, interval: interval)
            }

            return .none

        }) {
            renderers = updatedRenderers
        }
    }
}
