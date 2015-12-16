import Foundation

class SCubic: PathSegment  {

	var x2: NSNumber = 0
	var y2: NSNumber = 0
	var x: NSNumber = 0
	var y: NSNumber = 0

	init(x2: NSNumber = 0, y2: NSNumber = 0, x: NSNumber = 0, y: NSNumber = 0, absolute: Bool) {
		self.x2 = x2	
		self.y2 = y2	
		self.x = x	
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
