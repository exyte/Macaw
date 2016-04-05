import UIKit

extension CGFloat: Interpolable {
    public func interpolate(endValue: CGFloat, progress: Double) -> CGFloat {
        return self +  (endValue - self) * CGFloat(progress)
    }
}
