import UIKit

open class Gradient: Fill {

    public let userSpace: Bool
    public let stops: [Stop]

    public init(userSpace: Bool = false, stops: [Stop] = []) {
        self.userSpace = userSpace
        self.stops = stops
    }

    override func equals<T>(other: T) -> Bool where T: Fill {
        guard let other = other as? Gradient, userSpace == other.userSpace else {
            return false
        }

        if stops.isEmpty && other.stops.isEmpty {
            return true
        }

        return stops.elementsEqual(other.stops)
    }
    
    public func toCG() -> (colors: Array<CGColor>, locations: Array<NSNumber>) {
        var colors: Array<CGColor> = []
        var locations: Array<NSNumber> = []
        for stop in stops {
            colors += [stop.color.toCG()]
            locations += [NSNumber(value: stop.offset)]
        }
        
        return (colors, locations)
    }
}
