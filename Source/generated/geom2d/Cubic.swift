import Foundation

public class Cubic: PathSegment  {

	var x1: Double = 0
	var y1: Double = 0
	var x2: Double = 0
	var y2: Double = 0
	var x: Double = 0
	var y: Double = 0

	public init(x1: Double = 0, y1: Double = 0, x2: Double = 0, y2: Double = 0, x: Double = 0, y: Double = 0, absolute: Bool = false) {
		self.x1 = x1	
		self.y1 = y1	
		self.x2 = x2	
		self.y2 = y2	
		self.x = x	
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
