import Foundation
import RxSwift

public class Gradient: Fill {

	public let userSpace: Bool
	public let stops: [Stop]

	public init(userSpace: Bool = false, stops: [Stop] = []) {
		self.userSpace = userSpace
		self.stops = stops
	}

}
