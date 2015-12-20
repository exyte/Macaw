import Foundation

public class Elliptical: PathSegment  {

	var rx: NSNumber = 0
	var ry: NSNumber = 0
	var angle: NSNumber = 0
	var largeArc: Bool
	var sweep: Bool
	var x: NSNumber = 0
	var y: NSNumber = 0

	init(rx: NSNumber = 0, ry: NSNumber = 0, angle: NSNumber = 0, largeArc: Bool, sweep: Bool, x: NSNumber = 0, y: NSNumber = 0, absolute: Bool) {
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
