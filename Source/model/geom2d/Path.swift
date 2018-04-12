import Foundation

open class Path: Locus {

    open let segments: [PathSegment]

    public init(segments: [PathSegment] = []) {
        self.segments = segments
    }

    override open func bounds() -> Rect {
        return pathBounds(self)!
    }
    
    override open func toDictionary() -> [String:Any] {
        var pathSegments = [[String:Any]]()
        for segment in segments {
            pathSegments.append(segment.toDictionary())
        }
        return ["type": "Path", "segments": pathSegments]
    }
}
