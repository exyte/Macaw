import Foundation

class RoundRect: Locus  {

	var rect: Rect
	var rx: NSNumber = 0
	var ry: NSNumber = 0

	init(rect: Rect, rx: NSNumber = 0, ry: NSNumber = 0) {
		self.rect = rect	
		self.rx = rx	
		self.ry = ry	
	}

}
