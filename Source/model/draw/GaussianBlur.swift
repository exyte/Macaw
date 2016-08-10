import Foundation
import RxSwift

public class GaussianBlur: Effect  {

	public let radius: Double
	public let input: Effect?

	public init(radius: Double = 0, input: Effect? = nil) {
		self.radius = radius
		self.input = input
	}

}
