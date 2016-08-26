import Foundation
import RxSwift

public class PathSegment {

	public let type: PathSegmentType
	public let data: [Double]

	public init(type: PathSegmentType = .M, data: [Double] = []) {
		self.type = type
		self.data = data
	}

	// GENERATED NOT
	public func isAbsolute() -> Bool {
        switch type {
        case .M, .L, .H, .V, .C, .S, .Q, .T, .A:
            return true
        default:
            return false
        }
    }

}
