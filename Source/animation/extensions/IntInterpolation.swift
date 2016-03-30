import Foundation

extension Int: InterpolatingType {
    public func interpolate(endValue: Int, progress: Double) -> Int {

        return Int(Double(self) * (1.0 - progress) + Double(endValue) * progress)
    }
}
