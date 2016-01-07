import Foundation

public class VLine: PathSegment  {

	let y: Double

	public init(y: Double = 0, absolute: Bool = false) {
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
