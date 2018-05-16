import Foundation

open class PathSegment {

    open let type: PathSegmentType
    open let data: [Double]

    public init(type: PathSegmentType = .M, data: [Double] = []) {
        self.type = type
        self.data = data
    }

    open func isAbsolute() -> Bool {
        switch type {
        case .M, .L, .H, .V, .C, .S, .Q, .T, .A, .E:
            return true
        default:
            return false
        }
    }
}
