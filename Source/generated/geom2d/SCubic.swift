import Foundation

public class SCubic: PathSegment  {

	let x2: NSNumber
	let y2: NSNumber
	let x: NSNumber
	let y: NSNumber

	public init(x2: NSNumber = 0, y2: NSNumber = 0, x: NSNumber = 0, y: NSNumber = 0, absolute: Bool = false) {
		self.x2 = x2	
		self.y2 = y2	
		self.x = x	
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
