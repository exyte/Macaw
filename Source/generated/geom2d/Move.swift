import Foundation

public class Move: PathSegment  {

	var x: Double = 0
	var y: Double = 0

	public init(x: Double = 0, y: Double = 0, absolute: Bool = false) {
		self.x = x	
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
