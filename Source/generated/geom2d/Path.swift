import Foundation

public class Path: Locus  {

	let segments: [PathSegment]

	public init(segments: [PathSegment] = []) {
		self.segments = segments	
	}

}
