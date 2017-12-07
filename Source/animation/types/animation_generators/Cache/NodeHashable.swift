// TODO: Implement better hash

extension Node: Hashable {
    public var hashValue: Int {
        return Unmanaged.passUnretained(self).toOpaque().hashValue
    }
}

public func == (lhs: Node, rhs: Node) -> Bool {
    return lhs === rhs
}
