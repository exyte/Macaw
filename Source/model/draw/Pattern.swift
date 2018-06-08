open class Pattern: Fill {

    open let content: Node
    open let bounds: Rect
    open let userSpace: Bool
    open let contentUserSpace: Bool

    init(content: Node, bounds: Rect, userSpace: Bool = false, contentUserSpace: Bool = true) {
        self.content = content
        self.bounds = bounds
        self.userSpace = userSpace
        self.contentUserSpace = contentUserSpace
    }
}
