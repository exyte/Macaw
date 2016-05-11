import Foundation
import RxSwift

public class Polygon: Locus  {

	public let points: [Double]

	public init(points: [Double] = []) {
		self.points = points	
	}

}
