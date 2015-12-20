import Foundation

public class Polyline: Locus  {

	var points: [NSNumber] = []

	public init(points: [NSNumber] = []) {
		self.points = points	
	}

}
