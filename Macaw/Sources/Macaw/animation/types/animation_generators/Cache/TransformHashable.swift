extension Transform: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(m11)
        hasher.combine(m12)
        hasher.combine(m21)
        hasher.combine(m22)
        hasher.combine(dx)
        hasher.combine(dy)
    }
}

public func == (lhs: Transform, rhs: Transform) -> Bool {
    return lhs.m11 == rhs.m11 &&
        lhs.m12 == rhs.m12 &&
        lhs.m21 == rhs.m21 &&
        lhs.m22 == rhs.m22 &&
        lhs.dx == rhs.dx &&
        lhs.dy == rhs.dy
}
