import Foundation

public class Quadratic: PathSegment  {

	let x1: NSNumber
	let y1: NSNumber
	let x: NSNumber
	let y: NSNumber

	public init(x1: NSNumber = 0, y1: NSNumber = 0, x: NSNumber = 0, y: NSNumber = 0, absolute: Bool = false) {
		self.x1 = x1	
		self.y1 = y1	
		self.x = x	
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
