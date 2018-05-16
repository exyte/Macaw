open class Stroke {

    open let fill: Fill
    open let width: Double
    open let cap: LineCap
    open let join: LineJoin
    open let dashes: [Double]
    open let offset: Double

    public init(fill: Fill = Color.black, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = [], offset: Double = 0.0) {
        self.fill = fill
        self.width = width
        self.cap = cap
        self.join = join
        self.dashes = dashes
        self.offset = offset
    }
}
