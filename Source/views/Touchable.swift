class MTouchEvent: Hashable {
    let id: Int
    let x: Double
    let y: Double

    init(x: Double, y: Double, id: Int) {
        self.x = x
        self.y = y
        self.id = id
    }

    public var hashValue: Int {
        return id.hashValue
    }

    public static func == (lhs: MTouchEvent, rhs: MTouchEvent) -> Bool {
        return lhs.id == rhs.id
    }
}

protocol Touchable {
    func mTouchesBegan(_ touches: [MTouchEvent])
    func mTouchesMoved(_ touches: [MTouchEvent])
    func mTouchesEnded(_ touches: [MTouchEvent])
    func mTouchesCancelled(_ touches: [MTouchEvent])
}
