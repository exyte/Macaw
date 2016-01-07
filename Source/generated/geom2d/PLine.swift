import Foundation

public class PLine: PathSegment  {

	let x: Double
	let y: Double

	public init(x: Double = 0, y: Double = 0, absolute: Bool = false) {
		self.x = x	
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
