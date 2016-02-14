import Foundation

public class Rect: Locus  {

	var x: Double = 0
	var y: Double = 0
	var w: Double = 0
	var h: Double = 0

	public init(x: Double = 0, y: Double = 0, w: Double = 0, h: Double = 0) {
		self.x = x	
		self.y = y	
		self.w = w	
		self.h = h	
	}

	// GENERATED NOT
	public func round(rx: Double, ry: Double) -> RoundRect {
        return RoundRect(rect: Rect())
	}
	// GENERATED NOT
	public func contains(locus: Locus) -> Bool {
		return false
	}

}
