import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#endif

internal extension CGFloat {

    var doubleValue: Double {
        return Double(self)
    }
}
