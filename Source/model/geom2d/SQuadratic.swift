import Foundation
import RxSwift

public class SQuadratic: PathSegment  {

	public let x: Double
	public let y: Double

	public init(x: Double = 0, y: Double = 0, absolute: Bool = false) {
		self.x = x
		self.y = y
		super.init(
			absolute: absolute
		)
	}

}
