import Foundation

class Move: PathSegment  {

	var x: NSNumber = 0
	var y: NSNumber = 0


	init(x: NSNumber = 0, y: NSNumber = 0) {
		self.x = x	
		self.y = y	
	}

}
