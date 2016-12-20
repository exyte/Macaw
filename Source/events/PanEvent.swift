open class PanEvent : Event {

    open let dx: Double
    open let dy: Double

	init(node: Node, dx: Double, dy: Double) {
        self.dx = dx
        self.dy = dy
		super.init(node: node)
    }

}
