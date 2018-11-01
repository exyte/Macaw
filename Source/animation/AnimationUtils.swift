import Foundation

class AnimationUtils {
    class func absolutePosition(_ nodeRenderer: NodeRenderer?) -> Transform {
        return AnimationUtils.absoluteTransform(nodeRenderer, pos: nodeRenderer?.node()?.place ?? .identity)
    }

    class func absoluteTransform(_ nodeRenderer: NodeRenderer?, pos: Transform) -> Transform {
        var transform = pos
        var parentRenderer = nodeRenderer?.parentRenderer
        while parentRenderer != nil {

            if let canvas = parentRenderer?.node() as? SVGCanvas,
                let view = parentRenderer?.view as? MacawView {
                let rect = canvas.layout(size: view.bounds.size.toMacaw()).rect()
                let canvasTransform = view.contentLayout.layout(rect: rect, into: view.bounds.size.toMacaw()).move(dx: rect.x, dy: rect.y)
                transform = canvasTransform.concat(with: transform)
            } else if let node = parentRenderer?.node() {
                transform = node.place.concat(with: transform)
            }

            parentRenderer = parentRenderer?.parentRenderer
        }

        return transform
    }

    class func absoluteClip(_ nodeRenderer: NodeRenderer?) -> Locus? {
        // shouldn't this be a superposition of all parents' clips?
        let node = nodeRenderer?.node()
        if let _ = node?.clip {
            return node?.clip
        }

        var parentRenderer = nodeRenderer?.parentRenderer
        while parentRenderer != nil {
            if let _ = parentRenderer?.node()?.clip {
                return parentRenderer?.node()?.clip
            }

            parentRenderer = parentRenderer?.parentRenderer
        }

        return .none
    }

    private static var indexCache = [Node: Int]()

    class func animatedNodes(root: Node, animationCache: AnimationCache) -> [Node] {
        if animationCache.isAnimating(root) {
            return [root]
        }

        guard let rootGroup = root as? Group else {
            return []
        }

        var result = [Node]()
        rootGroup.contents.forEach { child in
            let childAnimatedNodes = animatedNodes(root: child, animationCache: animationCache)
            result.append(contentsOf: childAnimatedNodes)
        }

        return result
    }
}
