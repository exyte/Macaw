import Foundation

public class Elliptical: PathSegment  {

	let rx: Double
	let ry: Double
	let angle: Double
	let largeArc: Bool
	let sweep: Bool
	let x: Double
	let y: Double

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
