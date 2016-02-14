import Foundation

public class Elliptical: PathSegment  {

	var rx: Double = 0
	var ry: Double = 0
	var angle: Double = 0
	var largeArc: Bool = false
	var sweep: Bool = false
	var x: Double = 0
	var y: Double = 0

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
