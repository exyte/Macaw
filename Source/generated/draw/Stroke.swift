import Foundation

public class Stroke {

	var fill: Fill
	var width: Double = 1
	var cap: LineCap = .butt
	var join: LineJoin = .miter
	var dashes: [Double] = []

	public init(fill: Fill, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) {
		self.fill = fill	
		self.width = width	
		self.cap = cap	
		self.join = join	
		self.dashes = dashes	
	}

}
