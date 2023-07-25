import Foundation

#if os(iOS)
import UIKit
#endif

internal extension CGFloat {

    var doubleValue: Double {
        Double(self)
    }
}
