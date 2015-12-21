import Foundation

public class PLine: PathSegment  {

	let x: NSNumber
	let y: NSNumber

	public init(x: NSNumber = 0, y: NSNumber = 0, absolute: Bool = false) {
		self.x = x	
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
