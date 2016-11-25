import UIKit

func caTimingFunction(_ easing: Easing) -> CAMediaTimingFunction {
	switch easing {
	case .ease:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
	case .linear:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
	case .easeIn:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
	case .easeOut:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
	case .easeInOut:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
	}
}

func progressForTimingFunction(_ easing: Easing, progress: Double) -> Double {
    let t = progress
    
    switch easing {
    case .ease:
        return t
    case .linear:
        return t
    case .easeIn:
        return t * t
    case .easeOut:
        let p = 1.0 - t
        return p * p + 1.0
    case .easeInOut:
        if t < 0.5 {
            return 2.0 * t * t
        } else {
            return -2.0 * t * t + 4.0 * t - 1.0
        }
    }
}
