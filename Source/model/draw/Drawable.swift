open class Drawable {

    public let visible: Bool
    public let tag: [String]

    public init(visible: Bool = true, tag: [String] = []) {
        self.visible = visible
        self.tag = tag
    }
}
