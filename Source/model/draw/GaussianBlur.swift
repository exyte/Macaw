open class GaussianBlur: Effect {

    open let radius: Double

    public init(radius: Double = 0, input: Effect? = nil) {
        self.radius = radius
        super.init(input: input)
    }
}
