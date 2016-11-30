import Foundation

open class DropShadow: Effect {

	open let radius: Double
	open let offset: Point
	open let color: Color
	open let input: Effect?

	public init(radius: Double = 0, offset: Point = Point.origin, color: Color = Color.black, input: Effect? = nil) {
		self.radius = radius
		self.offset = offset
		self.color = color
		self.input = input
	}

}
