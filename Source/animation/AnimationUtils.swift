import Foundation

class AnimationUtils {

    class func absolutePosition(_ nodeRenderer: NodeRenderer?, _ context: AnimationContext) -> Transform {
        return AnimationUtils.absoluteTransform(nodeRenderer, context, pos: nodeRenderer?.node()?.place ?? .identity)
    }

    class func absoluteTransform(_ nodeRenderer: NodeRenderer?, _ context: AnimationContext, pos: Transform) -> Transform {
        var transform = pos
        var parentRenderer = nodeRenderer?.parentRenderer
        while parentRenderer != nil {
            if let node = parentRenderer?.node() {
                transform = node.place.concat(with: transform)
            }
            parentRenderer = parentRenderer?.parentRenderer
        }
        return transform.concat(with: context.getLayoutTransform(nodeRenderer))
    }

    class func absoluteClip(_ nodeRenderer: NodeRenderer?) -> Locus? {
        // shouldn't this be a superposition of all parents' clips?
        let node = nodeRenderer?.node()
        if let nodeClip = node?.clip {
            return nodeClip
        }

        var parentRenderer = nodeRenderer?.parentRenderer
        while parentRenderer != nil {
            if let parentClip = parentRenderer?.node()?.clip {
                return parentClip
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
