import Foundation

public class Line: Locus  {

	let x1: NSNumber
	let y1: NSNumber
	let x2: NSNumber
	let y2: NSNumber

	public init(x1: NSNumber = 0, y1: NSNumber = 0, x2: NSNumber = 0, y2: NSNumber = 0) {
		self.x1 = x1	
		self.y1 = y1	
		self.x2 = x2	
		self.y2 = y2	
	}

}
