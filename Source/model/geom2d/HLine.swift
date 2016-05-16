import Foundation
import RxSwift

public class HLine: PathSegment  {

	public let x: Double

	public init(x: Double = 0, absolute: Bool = false) {
		self.x = x	
		super.init(
			absolute: absolute
		)
	}

}
