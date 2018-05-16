open class Drawable {

    open let visible: Bool
    open let tag: [String]

    public init(visible: Bool = true, tag: [String] = []) {
        self.visible = visible
        self.tag = tag
    }
}
