import Foundation

public class HLine: PathSegment  {

	let x: NSNumber

	public init(x: NSNumber = 0, absolute: Bool = false) {
		self.x = x	
		super.init(
			absolute: absolute
		)
	}

}
