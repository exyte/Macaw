import Foundation

public class RoundRect: Locus  {

	var rect: Rect
	var rx: Double = 0
	var ry: Double = 0

	public init(rect: Rect, rx: Double = 0, ry: Double = 0) {
		self.rect = rect	
		self.rx = rx	
		self.ry = ry	
	}

}
