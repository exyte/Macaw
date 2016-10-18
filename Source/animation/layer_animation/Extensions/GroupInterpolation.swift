import Foundation

public protocol GroupInterpolation: Interpolable {
    
}

extension Array: GroupInterpolation {
    public func interpolate(_ endValue: Array, progress: Double) -> Array {
        return self
    }
}
