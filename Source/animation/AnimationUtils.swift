
import Foundation

class AnimationUtils {
	class func absolutePosition(node: Node) -> Transform {
		return AnimationUtils.absoluteTransform(node, pos: node.pos)
	}

	class func absoluteTransform(node: Node, pos: Transform) -> Transform {
		var transform = pos
		var parent = nodesMap.parents(node).first
		while parent != .None {
			transform = GeomUtils.concat(transform, t2: parent!.pos)
			parent = nodesMap.parents(parent!).first
		}

		return transform
	}
}
