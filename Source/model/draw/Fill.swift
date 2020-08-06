open class Fill: Equatable {

    public init() {
    }

    func equals<T>(other: T) -> Bool where T: Fill {
        fatalError("Equals can't be implemented for Fill")
    }
}

public func ==<T> (lhs: T, rhs: T) -> Bool where T: Fill {
    return lhs.equals(other: rhs)
}
