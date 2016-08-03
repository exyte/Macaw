
import Macaw

// TODO: Implement better hash

extension Node: Hashable {
	public var hashValue: Int {

		return unsafeAddressOf(self).hashValue
	}
}

public func == (lhs: Node, rhs: Node) -> Bool {
	return unsafeAddressOf(lhs) == unsafeAddressOf(rhs)
}
