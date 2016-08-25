
import UIKit

let nodesMap = NodesMap()
var parentsMap = [Node: Set<Node>]()

class NodesMap {
	var map = [Node: MacawView]()

	// MARK: - Macaw View
	func add(node: Node, view: MacawView) {
		map[node] = view

		if let group = node as? Group {
			group.contents.forEach { child in
				self.add(child, view: view)
			}
		}
	}

	func getView(node: Node) -> MacawView? {
		return map[node]
	}

	func remove(node: Node) {
		map.removeValueForKey(node)
		parentsMap.removeValueForKey(node)
	}

	// MARK: - Parents
	func add(node: Node, parent: Node) {
		if var nodesSet = parentsMap[node] {
			nodesSet.insert(parent)
		} else {
			parentsMap[node] = Set([parent])
		}
	}

	func parents(node: Node) -> [Node] {
		guard let nodesSet = parentsMap[node] else {
			return []
		}

		return Array(nodesSet)
	}
}
