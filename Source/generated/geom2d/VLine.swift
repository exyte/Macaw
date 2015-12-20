import Foundation

public class VLine: PathSegment  {

	var y: NSNumber = 0

	init(y: NSNumber = 0, absolute: Bool = false) {
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
