import Foundation
import RxSwift

public class Stroke {

	public let fill: Fill
	public let width: Double
	public let cap: LineCap
	public let join: LineJoin
	public let dashes: [Double]

	public init(fill: Fill = Color.black, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) {
		self.fill = fill
		self.width = width
		self.cap = cap
		self.join = join
		self.dashes = dashes
	}

}
