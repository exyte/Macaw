import Foundation

open class Path: Locus {

    open let segments: [PathSegment]

    public init(segments: [PathSegment] = []) {
        self.segments = segments
    }

    override open func bounds() -> Rect {
        return pathBounds(self)!
    }
    
    internal override func toDictionary() -> [String:Any] {
        var pathSegments = [[String:Any]]()
        for segment in segments {
            pathSegments.append(segment.toDictionary())
        }
        return ["type": "Path", "segments": pathSegments]
    }
    
    internal convenience init(dictionary: [String:Any]) {
        guard let array = dictionary["segments"] as? [[String:Any]] else { self.init(); return }
        var pathSegments = [PathSegment]()
        for dict in array {
            pathSegments.append(PathSegment(dictionary: dict))
        }
        self.init(segments: pathSegments)
    }
}
