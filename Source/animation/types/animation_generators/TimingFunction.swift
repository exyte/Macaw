import UIKit

func caTimingFunction(timingFunction: TimingFunction) -> CAMediaTimingFunction {
	switch timingFunction {
	case .Default:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
	case .Linear:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
	case .EaseIn:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
	case .EaseOut:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
	case .EaseInEaseOut:
		return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
	}
}
