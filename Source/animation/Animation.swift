import Foundation
import RxSwift

public extension SequenceType where Generator.Element: Animatable {
	func playAnimations() {
		self.forEach { animation in
			animation.play()
		}
	}

	func pauseAnimations() {
		self.forEach { animation in
			animation.pause()
		}
	}

	func removeAnimations() {
		self.forEach { animation in
			animation.remove()
		}
	}

	func moveAnimationsToPosition(position: Double) {
		self.forEach { animation in
			animation.moveToPosition(position)
		}
	}
}

enum AnimationType {
	case Unknown
	case AffineTransformation
}

public class Animatable {

	var shape: Group?
	var type = AnimationType.Unknown

	var shouldBeRemoved = false
	var paused = false

	var shouldUpdateSubscription = false

	public let currentProgress = Variable<Double>(0)

	func getDuration() -> Double { return 0 }

	func play() {
		paused = false
		shouldUpdateSubscription = true
	}
	func pause() { paused = true }
	func remove() { shouldBeRemoved = true }

	public func moveToPosition(position: Double) {
		shouldUpdateSubscription = true
		currentProgress.value = position
	}
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
