import Foundation
import RxSwift

enum AnimationType {
	case Unknown
	case AffineTransformation
}

public enum TimingFunction {
	case Default
	case Linear
	case EaseIn
	case EaseOut
	case EaseInEaseOut
}

public class Animatable {

	var shape: Group?
	var type = AnimationType.Unknown
	let ID: String

	// Options
	public var repeatCount = 0.0
	public var autoreverses = false
	public var timingFunction = TimingFunction.Linear

	public var completion: (() -> ())?

	func getDuration() -> Double { return 0 }

	public required init() {
		ID = NSUUID().UUIDString
	}

	public func remove() {
		removeFunc?()
	}

	// Private
	var removeFunc: (() -> ())?
}

// Animated property list https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html
public class Animation<T>: Animatable {

	let value: Variable<T>

	var start: T?
	var final: T?
	var vFunc: ((Double) -> T)?

	let duration: Double

	public required init(observableValue: Variable<T>, animationDuration: Double) {
		value = observableValue
		duration = animationDuration
	}

	public convenience init(observableValue: Variable<T>, startValue: T, finalValue: T, animationDuration: Double) {
		self.init(observableValue: observableValue, animationDuration: animationDuration)

		start = startValue
		final = finalValue
	}

	public convenience init(observableValue: Variable<T>, valueFunc: (Double) -> T, animationDuration: Double) {
		self.init(observableValue: observableValue, animationDuration: animationDuration)

		vFunc = valueFunc
	}

	public convenience init(observableValue: Variable<T>, finalValue: T, animationDuration: Double) {
		self.init(observableValue: observableValue, startValue: observableValue.value, finalValue: finalValue, animationDuration: animationDuration)
	}

	public override func getDuration() -> Double {
		return duration
	}
}
