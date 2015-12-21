import Foundation

public class Elliptical: PathSegment  {

	let rx: NSNumber
	let ry: NSNumber
	let angle: NSNumber
	let largeArc: Bool
	let sweep: Bool
	let x: NSNumber
	let y: NSNumber

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
