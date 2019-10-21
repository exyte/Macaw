open class RotateEvent: Event {

    public let angle: Double

    init(node: Node, angle: Double) {
        self.angle = angle
        super.init(node: node)
    }

}
