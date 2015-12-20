import Foundation

public class Path: Locus  {

	var segments: [PathSegment] = []

	public init(segments: [PathSegment] = []) {
		self.segments = segments	
	}

}
