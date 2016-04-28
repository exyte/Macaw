import Foundation

public class Rect: Locus {

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

	// GENERATED NOT
	public func union(rect: Rect) -> Rect {
		return Rect(
			x: min(self.x, rect.x),
			y: min(self.y, rect.y),
			w: max(self.x + self.w, rect.x + rect.w),
			h: max(self.y + self.h, rect.y + rect.h))
	}
}
