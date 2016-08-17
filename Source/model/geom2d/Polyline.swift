import Foundation
import RxSwift

public class Polyline: Locus {

	public let points: [Double]

	public init(points: [Double] = []) {
		self.points = points
	}

}
