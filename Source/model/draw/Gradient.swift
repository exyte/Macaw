open class Gradient: Fill {

    public let userSpace: Bool
    public let stops: [Stop]

    public init(userSpace: Bool = false, stops: [Stop] = []) {
        self.userSpace = userSpace
        self.stops = stops
    }

    override func equals<T>(other: T) -> Bool where T: Gradient {
        if userSpace == other.userSpace {

            if stops.isEmpty && other.stops.isEmpty {
                return true
            }

            return stops.elementsEqual(other.stops)

        } else {
            return false
        }
    }
}
