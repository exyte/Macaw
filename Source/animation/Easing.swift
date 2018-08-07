//
//  Easing.swift
//  Pods
//
//  Created by Yuri Strot on 9/2/16.
//
//

open class Easing {
    
    public static let ease: Easing = Ease()
    public static let linear: Easing = Easing()
    public static let easeIn: Easing = EaseIn()
    public static let easeOut: Easing = EaseOut()
    public static let easeInOut: Easing = EaseInOut()
    public static func spring(mass: Double = 1.0, stiffness: Double = 100.0, damping: Double = 10.0, initialVelocity: Double = 0.0) -> Spring {
        return Spring(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)
    }
    
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

public class Spring: Easing {
    let mass: Double
    let stiffness: Double
    let damping: Double
    let initialVelocity: Double
    init(mass: Double = 1.0, stiffness: Double = 100.0, damping: Double = 10.0, initialVelocity: Double = 0.0) {
        self.mass = mass
        self.stiffness = stiffness
        self.damping = damping
        self.initialVelocity = initialVelocity
    }
}
