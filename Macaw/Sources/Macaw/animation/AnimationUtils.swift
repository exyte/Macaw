import Foundation

class AbsoluteUtils {

    class func absolutePosition(_ nodeRenderer: NodeRenderer?, _ context: AnimationContext) -> Transform {
        return AbsoluteUtils.absoluteTransform(nodeRenderer, context, pos: nodeRenderer?.node.place ?? .identity)
    }

    class func absoluteTransform(_ nodeRenderer: NodeRenderer?, _ context: AnimationContext, pos: Transform) -> Transform {
        var transform = pos
        var parentRenderer = nodeRenderer?.parentRenderer
        while parentRenderer != nil {
            if let node = parentRenderer?.node {
                transform = node.place.concat(with: transform)
            }
            parentRenderer = parentRenderer?.parentRenderer
        }
        return transform.concat(with: context.getLayoutTransform(nodeRenderer))
    }

    class func absoluteClip(_ nodeRenderer: NodeRenderer?) -> Locus? {
        // shouldn't this be a superposition of all parents' clips?
        let node = nodeRenderer?.node
        if let nodeClip = node?.clip {
            return nodeClip
        }

        var parentRenderer = nodeRenderer?.parentRenderer
        while parentRenderer != nil {
            if let parentClip = parentRenderer?.node.clip {
                return parentClip
            }

            parentRenderer = parentRenderer?.parentRenderer
        }

        return .none
    }

    private static var indexCache = [Node: Int]()
}
