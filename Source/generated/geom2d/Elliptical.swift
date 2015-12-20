import Foundation

public class Elliptical: PathSegment  {

	var rx: NSNumber = 0
	var ry: NSNumber = 0
	var angle: NSNumber = 0
	var largeArc: Bool = false
	var sweep: Bool = false
	var x: NSNumber = 0
	var y: NSNumber = 0

	public init(rx: NSNumber = 0, ry: NSNumber = 0, angle: NSNumber = 0, largeArc: Bool = false, sweep: Bool = false, x: NSNumber = 0, y: NSNumber = 0, absolute: Bool = false) {
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
