import UIKit

extension CGPoint: InterpolatingType {
    public func interpolate(endValue: CGPoint, progress: Double) -> CGPoint {
        return CGPoint(x: self.x.interpolate(endValue.x, progress: progress),
                       y: self.y.interpolate(endValue.y, progress: progress))
    }
}
