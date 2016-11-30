import Foundation

open class Rect: Locus {

	open let x: Double
	open let y: Double
	open let w: Double
	open let h: Double

	public init(x: Double = 0, y: Double = 0, w: Double = 0, h: Double = 0) {
		self.x = x
		self.y = y
		self.w = w
		self.h = h
	}

	// GENERATED NOT
	open func round(rx: Double, ry: Double) -> RoundRect {
		return RoundRect(rect: self, rx: rx, ry: ry)
	}

    // GENERATED NOT
    public func round(r r: Double) -> RoundRect {
        return RoundRect(rect: self, rx: r, ry: r)
    }

	// GENERATED NOT
	open func contains(locus: Locus) -> Bool {
		return false
	}

	// GENERATED NOT
	class func zero() -> Rect {
		return Rect(x: 0.0, y: 0.0, w: 0.0, h: 0.0)
	}

	// GENERATED NOT
	open func move(offset: Point) -> Rect {
		return Rect(
			x: self.x + offset.x,
			y: self.y + offset.y,
			w: self.w,
			h: self.h)
	}

	// GENERATED NOT
	open func union(rect: Rect) -> Rect {
		return Rect(
			x: min(self.x, rect.x),
			y: min(self.y, rect.y),
			w: max(self.x + self.w, rect.x + rect.w) - min(self.x, rect.x),
			h: max(self.y + self.h, rect.y + rect.h) - min(self.y, rect.y))
	}

}
