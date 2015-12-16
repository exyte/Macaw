import Foundation

class Rect: Locus  {

	var x: NSNumber = 0
	var y: NSNumber = 0
	var w: NSNumber = 0
	var h: NSNumber = 0

	init(x: NSNumber = 0, y: NSNumber = 0, w: NSNumber = 0, h: NSNumber = 0) {
		self.x = x	
		self.y = y	
		self.w = w	
		self.h = h	
	}

	// GENERATED NOT
	func round(rx: NSNumber, ry: NSNumber) -> RoundRect {
        return RoundRect(rect: Rect())
	}
	// GENERATED NOT
	func contains(locus: Locus) -> Bool {
		return false
	}

}
