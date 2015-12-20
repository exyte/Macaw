import Foundation

public class Cubic: PathSegment  {

	var x1: NSNumber = 0
	var y1: NSNumber = 0
	var x2: NSNumber = 0
	var y2: NSNumber = 0
	var x: NSNumber = 0
	var y: NSNumber = 0

	init(x1: NSNumber = 0, y1: NSNumber = 0, x2: NSNumber = 0, y2: NSNumber = 0, x: NSNumber = 0, y: NSNumber = 0, absolute: Bool = false) {
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
