import Foundation

public class Rect: Locus  {

	public let x: Double
	public let y: Double
	public let w: Double
	public let h: Double

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
