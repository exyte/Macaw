import Foundation

class AnimationUtils {
    class func absolutePosition(_ node: Node) -> Transform {
        return AnimationUtils.absoluteTransform(node, pos: node.place)
    }

    class func absoluteTransform(_ node: Node, pos: Transform) -> Transform {
        var transform = pos
        var parent = nodesMap.parents(node).first
        while parent != .none {
            transform = GeomUtils.concat(t1: parent!.place, t2: transform)
            parent = nodesMap.parents(parent!).first
        }

        return transform
    }

    class func absoluteClip(node: Node) -> Locus? {

        if let _ = node.clip {
            return node.clip
        }

        var parent = nodesMap.parents(node).first
        while parent != .none {
            if let _ = parent?.clip {
                return parent?.clip
            }

            parent = nodesMap.parents(parent!).first
        }

        return .none
    }

    private static var indexCache = [Node: Int]()

    class func absoluteIndex(_ node: Node, useCache: Bool = false) -> Int {
        if useCache {
            if let cachedIndex = indexCache[node] {
                return cachedIndex
            }
        } else {
            indexCache.removeAll()
        }

        func childrenTotalCount(_ node: Node) -> Int {
            guard let group = node as? Group else {
                return 1
            }

            var count = 1
            for child in group.contents {
                count += childrenTotalCount(child)
            }

            return count
        }

        var zIndex = 0
        var parent = nodesMap.parents(node).first
        var currentNode = node
        while parent != .none {
            if let group = parent as? Group {
                let localIndex = group.contents.index(of: currentNode) ?? group.contents.count

                for i in 0..<localIndex {
                    zIndex += childrenTotalCount(group.contents[i])
                }
            }

            zIndex += 1

            currentNode = parent!
            parent = nodesMap.parents(parent!).first
        }

        if useCache {
            indexCache[node] = zIndex
        }

        return zIndex
    }

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
