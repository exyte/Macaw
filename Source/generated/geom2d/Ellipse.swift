import Foundation

public class Ellipse: Locus  {

	var cx: Double = 0
	var cy: Double = 0
	var rx: Double = 0
	var ry: Double = 0

	public init(cx: Double = 0, cy: Double = 0, rx: Double = 0, ry: Double = 0) {
		self.cx = cx	
		self.cy = cy	
		self.rx = rx	
		self.ry = ry	
	}

	// GENERATED NOT
	public func arc(shift: Double, extent: Double) -> Arc {
		return Arc(ellipse: Ellipse())
	}

}
