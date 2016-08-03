import Foundation
import RxSwift

public class Elliptical: PathSegment  {

	public let rx: Double
	public let ry: Double
	public let angle: Double
	public let largeArc: Bool
	public let sweep: Bool
	public let x: Double
	public let y: Double

	public init(rx: Double = 0, ry: Double = 0, angle: Double = 0, largeArc: Bool = false, sweep: Bool = false, x: Double = 0, y: Double = 0, absolute: Bool = false) {
		self.rx = rx
		self.ry = ry
		self.angle = angle
		self.largeArc = largeArc
		self.sweep = sweep
		self.x = x
		self.y = y
		super.init(
			absolute: absolute
		)
	}

}
