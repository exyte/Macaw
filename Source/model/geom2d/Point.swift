import Foundation
import RxSwift

public class Point: Locus  {

	public let x: Double
	public let y: Double

	public init(x: Double = 0, y: Double = 0) {
		self.x = x
		self.y = y
	}


	// GENERATED NOT
	public func add(point: Point) -> Point {
		return Point(
			x: self.x + point.x,
			y: self.y + point.y)
	}

	// GENERATED NOT
	public class func zero() -> Point {
		return Point(x: 0.0, y: 0.0)
	}
}