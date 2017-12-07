open class TapEvent: Event {

    open let location: Point

    init(node: Node, location: Point) {
        self.location = location
        super.init(node: node)
    }

}
