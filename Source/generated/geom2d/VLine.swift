import Foundation

class VLine: PathSegment  {

	var y: NSNumber = 0

	init(y: NSNumber = 0, absolute: Bool) {
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
