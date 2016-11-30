import Foundation

open class Stop {

	open let offset: Double
	open let color: Color

	public init(offset: Double = 0, color: Color) {
		self.offset = offset
		self.color = color
	}

}
