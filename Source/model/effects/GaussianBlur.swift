import Foundation

open class GaussianBlur: Effect {

    open let radius: Double

    public init(radius: Double = 0) {
        self.radius = radius
    }
}
