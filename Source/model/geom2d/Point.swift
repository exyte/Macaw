import Foundation
import RxSwift

public class Point: Locus {

	public let x: Double
	public let y: Double

	public static let origin: Point = Point( x: 0, y: 0 )

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

}
