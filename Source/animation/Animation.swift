import Foundation
import RxSwift

enum AnimationType {
	case Unknown
	case AffineTransformation
}

public class Animatable {

	var shape: Group?
	var type = AnimationType.Unknown

	// Options
	public var  repeatCount = 0.0
	public var autoreverses = false

	func getDuration() -> Double { return 0 }
}

public class Animation<T>: Animatable {

	let value: Variable<T>

	let start: T
	let final: T
	let duration: Double

	public required init(observableValue: Variable<T>, startValue: T, finalValue: T, animationDuration: Double) {
		value = observableValue
		start = startValue
		final = finalValue
		duration = animationDuration
	}

	public convenience init(observableValue: Variable<T>, finalValue: T, animationDuration: Double) {
		self.init(observableValue: observableValue, startValue: observableValue.value, finalValue: finalValue, animationDuration: animationDuration)
	}

	public override func getDuration() -> Double {
		return duration
	}
}
