import Foundation

public class Stroke {

	let fill: Fill
	let width: Double
	let cap: LineCap
	let join: LineJoin
	let dashes: [Double]

	public init(fill: Fill, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) {
		self.fill = fill	
		self.width = width	
		self.cap = cap	
		self.join = join	
		self.dashes = dashes	
	}

}
