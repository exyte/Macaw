open class TapEvent: Event {

    public let location: Point

    init(node: Node, location: Point) {
        self.location = location
        super.init(node: node)
    }

}
