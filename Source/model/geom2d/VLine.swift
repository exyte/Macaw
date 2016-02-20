import Foundation

public class VLine: PathSegment  {

	public let y: Double

	public init(y: Double = 0, absolute: Bool = false) {
		self.y = y	
		super.init(
			absolute: absolute
		)
	}

}
