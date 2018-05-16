open class Gradient: Fill {

    open let userSpace: Bool
    open let stops: [Stop]

    public init(userSpace: Bool = false, stops: [Stop] = []) {
        self.userSpace = userSpace
        self.stops = stops
    }
}
