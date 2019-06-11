open class Pattern: Fill {

    public let viewBox: Rect
    public let content: Node
    public let bounds: Rect
    public let userSpace: Bool
    public let position: Transform

    public init(content: Node, bounds: Rect, viewBox: Rect, userSpace: Bool = false, position: Transform) {
        self.viewBox = viewBox
        self.content = content
        self.bounds = bounds
        self.userSpace = userSpace
        self.position = position
    }
}
