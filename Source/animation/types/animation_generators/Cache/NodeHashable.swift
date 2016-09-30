

// TODO: Implement better hash

extension Node: Hashable {
	public var hashValue: Int {

		return Unmanaged.passUnretained(self).toOpaque().hashValue
	}
}

public func == (lhs: Node, rhs: Node) -> Bool {
	return Unmanaged.passUnretained(lhs).toOpaque() == Unmanaged.passUnretained(rhs).toOpaque()
}
