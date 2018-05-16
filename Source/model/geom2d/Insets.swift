open class Insets {

    open let top: Double
    open let right: Double
    open let bottom: Double
    open let left: Double

    public init(top: Double = 0, right: Double = 0, bottom: Double = 0, left: Double = 0) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }
}
