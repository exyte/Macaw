import Foundation

open class Path: Locus {

	open let segments: [PathSegment]

	public init(segments: [PathSegment] = []) {
		self.segments = segments
	}

}
