import Foundation
import RxSwift

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
	public func round(rx rx: Double, ry: Double) -> RoundRect {
		return RoundRect(rect: Rect())
	}

	// GENERATED NOT
	public func contains(locus locus: Locus) -> Bool {
		return false
	}

	// GENERATED NOT
	class func zero() -> Rect {
		return Rect(x: 0.0, y: 0.0, w: 0.0, h: 0.0)
	}

	// GENERATED NOT
	public func move(offset offset: Point) -> Rect {
		return Rect(
			x: self.x + offset.x,
			y: self.y + offset.y,
			w: self.w,
			h: self.h)
	}

	// GENERATED NOT
	public func union(rect rect: Rect) -> Rect {
		return Rect(
			x: min(self.x, rect.x),
			y: min(self.y, rect.y),
			w: max(self.x + self.w, rect.x + rect.w) - min(self.x, rect.x),
			h: max(self.y + self.h, rect.y + rect.h) - min(self.y, rect.y))
	}

}
