import UIKit

extension CGFloat: InterpolatingType {
    public func interpolate(endValue: CGFloat, progress: Double) -> CGFloat {
        return self * CGFloat(1.0 - progress) + endValue * CGFloat(progress)
    }
}
