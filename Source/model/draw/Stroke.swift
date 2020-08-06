open class Stroke: Equatable {

    public let fill: Fill
    public let width: Double
    public let cap: LineCap
    public let join: LineJoin
    public let miterLimit: Double
    public let dashes: [Double]
    public let offset: Double

    public init(fill: Fill = Color.black, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, miterLimit: Double = 10, dashes: [Double] = [], offset: Double = 0.0) {
        self.fill = fill
        self.width = width
        self.cap = cap
        self.join = join
        self.miterLimit = miterLimit
        self.dashes = dashes
        self.offset = offset
    }
}

public func ==<T> (lhs: T, rhs: T) -> Bool where T: Stroke {
    return lhs.fill == rhs.fill
        && lhs.width == rhs.width
        && lhs.cap == rhs.cap
        && lhs.join == rhs.join
        && lhs.miterLimit == rhs.miterLimit
        && lhs.dashes == rhs.dashes
        && lhs.offset == rhs.offset
}
