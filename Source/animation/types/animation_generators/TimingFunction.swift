#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

func caTimingFunction(_ easing: Easing) -> CAMediaTimingFunction {
    if easing === Easing.ease {
        return CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
    }
    if easing === Easing.linear {
        return CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    }
    if easing === Easing.easeIn {
        return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
    }
    if easing === Easing.easeOut {
        return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    }
    if easing === Easing.easeInOut {
        return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    }
    return CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
}

