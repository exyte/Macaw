import Foundation
import RxSwift

enum AnimationType {
	case Unknown
	case AffineTransformation
	case Opacity
	case Sequence
	case Combine
	case Empty
}

public enum TimingFunction {
	case Default
	case Linear
	case EaseIn
	case EaseOut
	case EaseInEaseOut
}

public class Animation {

	var node: Node?
	var type = AnimationType.Unknown
	let ID: String
	var next: Animation?

	// Options

	// NOT YET FULLY SUPPORTED
	public var repeatCount = 0.0
	public var autoreverses = false

	public var timingFunction = TimingFunction.Linear

	public var completion: (() -> ())?
	public var onProgressUpdate: ((Double) -> ())?

	func getDuration() -> Double { return 0 }

	public init() {
		ID = NSUUID().UUIDString
	}

	public func start() {
		animationProducer.addAnimation(self)
	}

	public func stop() {
		removeFunc?()
	}

	public func reverse() -> Animation {
		return self
	}

	// Private
	var removeFunc: (() -> ())?
	var progress = 0.0
}

// Animated property list https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreAnimation_guide/AnimatableProperties/AnimatableProperties.html
internal class AnimationImpl<T: Interpolable>: Animation {

	let value: Variable<T>
	let vFunc: ((Double) -> T)
	let duration: Double
	let logicalFps: UInt
	let autostart: Bool

	init(observableValue: Variable<T>, valueFunc: (Double) -> T, animationDuration: Double, autostart: Bool = false, fps: UInt = 30) {
		value = observableValue
		duration = animationDuration
		vFunc = valueFunc
		logicalFps = fps
		self.autostart = autostart

		super.init()

		if autostart {
			start()
		}
	}

	convenience init(observableValue: Variable<T>, startValue: T, finalValue: T, animationDuration: Double) {
		let interpolationFunc = { (t: Double) -> T in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(observableValue: observableValue, valueFunc: interpolationFunc, animationDuration: animationDuration)
	}

	convenience init(observableValue: Variable<T>, finalValue: T, animationDuration: Double) {
		self.init(observableValue: observableValue, startValue: observableValue.value, finalValue: finalValue, animationDuration: animationDuration)
	}

	public override func getDuration() -> Double {
		return duration
	}
}

// For sequence completion
class EmptyAnimation: Animation {
	required init(completion: (() -> ())) {
		super.init()

		self.completion = completion
		self.type = .Empty
	}
}

// MARK: - Animation Description

public class AnimationDescription <T> {
	public let valueFunc: (Double) -> T
	public var duration = 0.0
	public init(valueFunc: (Double) -> T, duration: Double = 1.0) {
		self.valueFunc = valueFunc
		self.duration = duration
	}

	public func t(duration: Double) -> AnimationDescription<T> {
		return AnimationDescription(valueFunc: valueFunc, duration: duration)
	}
}

