import Foundation

open class Polygon: Locus {

	open let points: [Double]

	public init(points: [Double] = []) {
		self.points = points
	}

}
