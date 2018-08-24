#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

func caTimingFunction(_ easing: Easing) -> CAMediaTimingFunction {
    if easing === Easing.ease {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
    }
    if easing === Easing.linear {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    }
    if easing === Easing.easeIn {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    }
    if easing === Easing.easeOut {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    }
    if easing === Easing.easeInOut {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    }
    return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
}

