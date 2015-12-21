import Foundation

public class Stroke {

	let fill: Fill?
	let width: Float
	let cap: LineCap?
	let join: LineJoin?
	let dashes: [NSNumber]

	public init(fill: Fill? = nil, width: Float = 1, cap: LineCap? = nil, join: LineJoin? = nil, dashes: [NSNumber] = []) {
		self.fill = fill	
		self.width = width	
		self.cap = cap	
		self.join = join	
		self.dashes = dashes	
	}

}
