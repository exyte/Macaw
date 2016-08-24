
import UIKit

let nodesMap = NodesMap()
class NodesMap {
	var map = [Node: MacawView]()

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
	}
}
