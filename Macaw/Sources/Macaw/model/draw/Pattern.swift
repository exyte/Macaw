open class Pattern: Fill {

    public let content: Node
    public let bounds: Rect
    public let userSpace: Bool

    public init(content: Node, bounds: Rect, userSpace: Bool = false) {
        self.content = content
        self.bounds = bounds
        self.userSpace = userSpace
    }
}
