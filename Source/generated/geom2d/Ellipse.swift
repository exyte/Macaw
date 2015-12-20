import Foundation

public class Ellipse: Locus  {

	var cx: NSNumber = 0
	var cy: NSNumber = 0
	var rx: NSNumber = 0
	var ry: NSNumber = 0

	public init(cx: NSNumber = 0, cy: NSNumber = 0, rx: NSNumber = 0, ry: NSNumber = 0) {
		self.cx = cx	
		self.cy = cy	
		self.rx = rx	
		self.ry = ry	
	}

	// GENERATED NOT
	public func arc(shift: NSNumber, extent: NSNumber) -> Arc {
         // TODO initial implementation
		return Arc(ellipse: Ellipse())
	}

}
