import Foundation

class Path: Locus  {

	var segments: [PathSegment]


	init(segments: [PathSegment]) {
		self.segments = segments	
	}

}
