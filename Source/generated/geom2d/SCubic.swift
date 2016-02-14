import Foundation

public class SCubic: PathSegment  {

	var x2: Double = 0
	var y2: Double = 0
	var x: Double = 0
	var y: Double = 0

	public init(x2: Double = 0, y2: Double = 0, x: Double = 0, y: Double = 0, absolute: Bool = false) {
		self.x2 = x2	
		self.y2 = y2	
		self.x = x	
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
