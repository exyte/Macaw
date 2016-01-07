import Foundation

public class Ellipse: Locus  {

	let cx: Double
	let cy: Double
	let rx: Double
	let ry: Double

	public init(cx: Double = 0, cy: Double = 0, rx: Double = 0, ry: Double = 0) {
		self.cx = cx	
		self.cy = cy	
		self.rx = rx	
		self.ry = ry	
	}

	// GENERATED NOT
	public func arc(shift: Double, extent: Double) -> Arc {
		return Arc()
	}

}
