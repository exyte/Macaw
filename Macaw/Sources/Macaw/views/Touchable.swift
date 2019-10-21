class MTouchEvent: Hashable {
    let id: Int
    let x: Double
    let y: Double

    init(x: Double, y: Double, id: Int) {
        self.x = x
        self.y = y
        self.id = id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: MTouchEvent, rhs: MTouchEvent) -> Bool {
        return lhs.id == rhs.id
    }
}

protocol Touchable {
    func mTouchesBegan(_ touches: Set<MTouch>, with event: MEvent?)
    func mTouchesMoved(_ touches: Set<MTouch>, with event: MEvent?)
    func mTouchesEnded(_ touches: Set<MTouch>, with event: MEvent?)
    func mTouchesCancelled(_ touches: Set<MTouch>, with event: MEvent?)
}
