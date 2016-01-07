import Foundation

public class Quadratic: PathSegment  {

	let x1: Double
	let y1: Double
	let x: Double
	let y: Double

	public init(x1: Double = 0, y1: Double = 0, x: Double = 0, y: Double = 0, absolute: Bool = false) {
		self.x1 = x1	
		self.y1 = y1	
		self.x = x	
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
