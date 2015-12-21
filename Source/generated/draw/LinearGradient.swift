import Foundation

public class LinearGradient: Fill  {

	let userSpace: Bool
	let stops: [Stop]
	let x1: NSNumber
	let y1: NSNumber
	let x2: NSNumber
	let y2: NSNumber

	public init(userSpace: Bool = false, stops: [Stop] = [], x1: NSNumber = 0, y1: NSNumber = 0, x2: NSNumber = 0, y2: NSNumber = 0) {
		self.userSpace = userSpace	
		self.stops = stops	
		self.x1 = x1	
		self.y1 = y1	
		self.x2 = x2	
		self.y2 = y2	
	}

}
