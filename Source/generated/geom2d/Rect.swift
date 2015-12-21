import Foundation

public class Rect: Locus  {

	let x: NSNumber
	let y: NSNumber
	let w: NSNumber
	let h: NSNumber

	public init(x: NSNumber = 0, y: NSNumber = 0, w: NSNumber = 0, h: NSNumber = 0) {
		self.x = x	
		self.y = y	
		self.w = w	
		self.h = h	
	}

	// GENERATED NOT
	public func round(rx: NSNumber, ry: NSNumber) -> RoundRect {
		return RoundRect()
	}
	// GENERATED NOT
	public func contains(locus: Locus?) -> Bool {
		return false
	}

}
