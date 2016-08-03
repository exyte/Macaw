
import Macaw

// TODO: Implement better hash

extension Node: Hashable {
	public var hashValue: Int {

		return pos.hashValue
	}
}

public func == (lhs: Node, rhs: Node) -> Bool {
	return lhs.pos == rhs.pos
}
