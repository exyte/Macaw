#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

func caTimingFunction(_ easing: Easing) -> CAMediaTimingFunction {
    if easing === Easing.ease {
        return CAMediaTimingFunction(name: MCAMediaTimingFunctionName.default)
    }
    if easing === Easing.linear {
        return CAMediaTimingFunction(name: MCAMediaTimingFunctionName.linear)
    }
    if easing === Easing.easeIn {
        return CAMediaTimingFunction(name: MCAMediaTimingFunctionName.easeIn)
    }
    if easing === Easing.easeOut {
        return CAMediaTimingFunction(name: MCAMediaTimingFunctionName.easeOut)
    }
    if easing === Easing.easeInOut {
        return CAMediaTimingFunction(name: MCAMediaTimingFunctionName.easeInEaseOut)
    }
    return CAMediaTimingFunction(name: MCAMediaTimingFunctionName.linear)
}
