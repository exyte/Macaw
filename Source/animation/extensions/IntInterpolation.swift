import Foundation

extension Int: Interpolable {
    public func interpolate(endValue: Int, progress: Double) -> Int {
        return Int(Double(self) + Double(endValue - self) * progress)
    }
}
