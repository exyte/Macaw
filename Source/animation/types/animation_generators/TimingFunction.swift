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
