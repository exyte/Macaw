import Foundation

open class Locus {

	public init() {
	}

	// GENERATED NOT
	open func bounds() -> Rect {
		return Rect()
	}

	// GENERATED NOT
	open func stroke(with: Stroke) -> Shape {
		return Shape(form: self, stroke: with)
	}

	// GENERATED NOT
	open func fill(with: Fill) -> Shape {
		return Shape(form: self, fill: with)
	}

	// GENERATED NOT
	open func stroke(fill: Fill = Color.black, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) -> Shape {
		return Shape(form: self, stroke: Stroke(fill: fill, width: width, cap: cap, join: join, dashes: dashes))
	}

}
