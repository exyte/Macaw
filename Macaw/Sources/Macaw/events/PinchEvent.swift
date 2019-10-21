open class PinchEvent: Event {

    public let scale: Double

    init(node: Node, scale: Double) {
        self.scale = scale
        super.init(node: node)
    }

}
