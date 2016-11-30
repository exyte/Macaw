import Foundation

open class GaussianBlur: Effect {

	open let radius: Double
	open let input: Effect?

	public init(radius: Double = 0, input: Effect? = nil) {
		self.radius = radius
		self.input = input
	}

}
