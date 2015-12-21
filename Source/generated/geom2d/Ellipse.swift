import Foundation

public class Ellipse: Locus  {

	let cx: NSNumber
	let cy: NSNumber
	let rx: NSNumber
	let ry: NSNumber

	public init(cx: NSNumber = 0, cy: NSNumber = 0, rx: NSNumber = 0, ry: NSNumber = 0) {
		self.cx = cx	
		self.cy = cy	
		self.rx = rx	
		self.ry = ry	
	}

	// GENERATED NOT
	public func arc(shift: NSNumber, extent: NSNumber) -> Arc {
		return Arc()
	}

}
