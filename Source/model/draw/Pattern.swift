open class Pattern: Fill {

    open let content: Node
    open let bounds: Rect
    open let userSpace: Bool

    init(content: Node, bounds: Rect, userSpace: Bool = false) {
        self.content = content
        self.bounds = bounds
        self.userSpace = userSpace
    }
}
