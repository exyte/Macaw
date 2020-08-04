import Foundation

open class PathSegment: Equatable {

    public let type: PathSegmentType
    public let data: [Double]

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

    public static func == (lhs: PathSegment, rhs: PathSegment) -> Bool {
        return lhs.type == rhs.type
            && lhs.data == rhs.data
    }
}
