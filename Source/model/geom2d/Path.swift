import Foundation

public class Path: Locus  {

	public let segments: [PathSegment]

	public init(segments: [PathSegment] = []) {
		self.segments = segments	
	}

}
