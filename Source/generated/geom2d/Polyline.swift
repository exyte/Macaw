import Foundation

public class Polyline: Locus  {

	var points: [NSNumber] = []

	init(points: [NSNumber] = []) {
		self.points = points	
	}

}
