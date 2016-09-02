import UIKit

func caTimingFunction(easing: Easing) -> CAMediaTimingFunction {
	switch easing {
	case .Ease:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
	case .Linear:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
	case .EaseIn:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
	case .EaseOut:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
	case .EaseInOut:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
	}
}
