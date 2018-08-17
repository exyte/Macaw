//
//  Easing.swift
//  Pods
//
//  Created by Yuri Strot on 9/2/16.
//
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

open class Easing {

    public static let ease: Easing = Ease()
    public static let linear: Easing = Easing()
    public static let easeIn: Easing = EaseIn()
    public static let easeOut: Easing = EaseOut()
    public static let easeInOut: Easing = EaseInOut()
    public static let elasticInOut: Easing = ElasticInOut()

    open func caTimingFunction() -> CAMediaTimingFunction {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    }

    open func progressForTimingFunction(progress: Double) -> Double {
        return progress
    }
}

private class Ease: Easing {
    override open func caTimingFunction() -> CAMediaTimingFunction {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
    }
}

private class EaseIn: Easing {
    override open func caTimingFunction() -> CAMediaTimingFunction {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    }
    override open func progressForTimingFunction(progress t: Double) -> Double {
        return t * t
    }
}

private class EaseOut: Easing {
    override open func caTimingFunction() -> CAMediaTimingFunction {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    }
    override open func progressForTimingFunction(progress t: Double) -> Double {
        return -(t * (t - 2))
    }
}

private class EaseInOut: Easing {
    override open func caTimingFunction() -> CAMediaTimingFunction {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    }
    override open func progressForTimingFunction(progress t: Double) -> Double {
        if t < 0.5 {
            return 2.0 * t * t
        } else {
            return -2.0 * t * t + 4.0 * t - 1.0
        }
    }
}

private class ElasticInOut: Easing {
    override open func progressForTimingFunction(progress: Double) -> Double {
        if progress == 0 {
            return 0
        }
        var t = progress / 0.5
        if t == 2 {
            return 1
        }
        let p = 0.3 * 1.5
        let s = p / 4

        if t < 1 {
            t -= 1
            let postFix = pow(2, 10 * t)
            return (-0.5 * (postFix * sin((t - s) * (2 * .pi) / p)))
        }
        t -= 1
        let postFix = pow(2, -10 * t)
        return (postFix * sin((t - s) * (2 * .pi) / p ) * 0.5 + 1)
    }
}
