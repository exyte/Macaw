
import UIKit

let nodesMap = NodesMap()
var parentsMap = [Node: Set<Node>]()

class NodesMap {
	var map = [Node: MacawView]()

	// MARK: - Macaw View
	func add(_ node: Node, view: MacawView) {
		map[node] = view

		if let group = node as? Group {
			group.contents.forEach { child in
				self.add(child, view: view)
				self.add(child, parent: node)
			}
		}
	}

	func getView(_ node: Node) -> MacawView? {
		return map[node]
	}

	func remove(_ node: Node) {
		map.removeValue(forKey: node)
		parentsMap.removeValue(forKey: node)
	}

	// MARK: - Parents
	func add(_ node: Node, parent: Node) {
		if var nodesSet = parentsMap[node] {
			nodesSet.insert(parent)
		} else {
			parentsMap[node] = Set([parent])
		}
        
        if let group = node as? Group {
            group.contents.forEach { child in
                self.add(child, parent: node)
            }
        }
	}

	func parents(_ node: Node) -> [Node] {
		guard let nodesSet = parentsMap[node] else {
			return []
		}

		return Array(nodesSet)
	}
    
    func replace(node: Node, to: Node) {
        let parents = parentsMap[node]
        let hostingView = map[node]
        
        remove(node)
        
        parents?.forEach { parent in
            guard let group = parent as? Group else {
                return
            }
            
            var contents = group.contents
            var indexToInsert = 0
            if let index = contents.index(of: node) {
                contents.remove(at: index)
                indexToInsert = index
            }
            
            contents.insert(to, at: indexToInsert)
            group.contents = contents
            
            add(to, parent: parent)
        }
        
        if let view = hostingView {
            add(to, view: view)
        }
        
    }
}
