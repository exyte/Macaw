import Foundation

public class LinearGradient: Fill  {

	public let userSpace: Bool
	public let stops: [Stop]
	public let x1: Double
	public let y1: Double
	public let x2: Double
	public let y2: Double

	public init(userSpace: Bool = false, stops: [Stop] = [], x1: Double = 0, y1: Double = 0, x2: Double = 0, y2: Double = 0) {
		self.userSpace = userSpace	
		self.stops = stops	
		self.x1 = x1	
		self.y1 = y1	
		self.x2 = x2	
		self.y2 = y2	
	}

}
