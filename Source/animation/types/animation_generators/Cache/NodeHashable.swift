// TODO: Implement better hash

public func == (lhs: Node, rhs: Node) -> Bool {
    lhs === rhs
}

extension NodeRenderer: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(Unmanaged.passUnretained(self).toOpaque())
    }
}

func == (lhs: NodeRenderer, rhs: NodeRenderer) -> Bool {
    lhs === rhs
}
