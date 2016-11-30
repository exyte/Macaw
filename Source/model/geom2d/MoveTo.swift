import Foundation

open class MoveTo: PathBuilder {

	// GENERATED NOT
	public init(x: Double, y: Double) {
        super.init(segment: PathSegment(type: .M, data: [x, y]))
	}

}
