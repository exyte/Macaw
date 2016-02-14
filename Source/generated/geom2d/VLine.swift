import Foundation

public class VLine: PathSegment  {

	var y: Double = 0

	public init(y: Double = 0, absolute: Bool = false) {
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
