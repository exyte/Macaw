import Foundation

public class VLine: PathSegment  {

	let y: NSNumber

	public init(y: NSNumber = 0, absolute: Bool = false) {
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
