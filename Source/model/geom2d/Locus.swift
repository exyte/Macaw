import Foundation
import RxSwift

public class Locus {

	public init() {
	}

	// GENERATED NOT
	public func bounds() -> Rect {
		return Rect()
	}

	// GENERATED NOT
	public func stroke(with with: Stroke) -> Shape {
		return Shape(form: self, stroke: with)
	}

	// GENERATED NOT
	public func fill(with with: Fill) -> Shape {
		return Shape(form: self, fill: with)
	}

	// GENERATED NOT
	public func stroke(fill fill: Fill = Color.black, width: Double = 1, cap: LineCap = .butt, join: LineJoin = .miter, dashes: [Double] = []) -> Shape {
		return Shape(form: self, stroke: Stroke(fill: fill, width: width, cap: cap, join: join, dashes: dashes))
	}

}
