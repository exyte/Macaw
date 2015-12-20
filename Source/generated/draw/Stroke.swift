import Foundation

public class Stroke {

	var fill: Fill? = nil
	var width: Float = 1
	var cap: LineCap? = nil
	var join: LineJoin? = nil
	var dashes: [NSNumber] = []

	public init(fill: Fill? = nil, width: Float = 1, cap: LineCap? = nil, join: LineJoin? = nil, dashes: [NSNumber] = []) {
		self.fill = fill	
		self.width = width	
		self.cap = cap	
		self.join = join	
		self.dashes = dashes	
	}

}
