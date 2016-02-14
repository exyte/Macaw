import Foundation

public class HLine: PathSegment  {

	var x: Double = 0

	public init(x: Double = 0, absolute: Bool = false) {
		self.x = x	
		super.init(
			absolute: absolute
		)
	}

}
