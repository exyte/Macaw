extension Transform: Hashable {
    public var hashValue: Int {
        return m11.hashValue ^
            m12.hashValue ^
            m21.hashValue ^
            m22.hashValue ^
            dx.hashValue ^
            dy.hashValue
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
