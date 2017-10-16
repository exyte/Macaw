open class PanEvent: Event {

    open let dx: Double
    open let dy: Double
    open let count: Int

    init(node: Node, dx: Double, dy: Double, count: Int) {
        self.dx = dx
        self.dy = dy
        self.count = count
        super.init(node: node)
    }

}
