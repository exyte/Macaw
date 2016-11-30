import Foundation

open class Polyline: Locus {

	open let points: [Double]

	public init(points: [Double] = []) {
		self.points = points
	}

}
