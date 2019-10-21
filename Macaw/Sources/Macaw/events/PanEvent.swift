open class PanEvent: Event {

    public let dx: Double
    public let dy: Double
    public let count: Int

    init(node: Node, dx: Double, dy: Double, count: Int) {
        self.dx = dx
        self.dy = dy
        self.count = count
        super.init(node: node)
    }

}
