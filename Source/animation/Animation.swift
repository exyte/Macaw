import Foundation

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
	case Transition
}

public class Animatable {

	var shouldBeRemoved = false
	var paused = false

	var shouldUpdateSubscription = false

	public let currentProgress = ObservableValue<Double>(value: 0)

	func animate(progress: Double) { }
	func getDuration() -> Double { return 0 }

	func play() {
		paused = false
		shouldUpdateSubscription = true
	}
	func pause() { paused = true }
	func remove() { shouldBeRemoved = true }

	public func moveToPosition(position: Double) {
		shouldUpdateSubscription = true
		currentProgress.set(position)
	}
}

public class Animation<T: Interpolable>: Animatable {

	let value: ObservableValue<T>

	let start: T
	let final: T
	let duration: Double

	public required init(observableValue: ObservableValue<T>, startValue: T, finalValue: T, animationDuration: Double) {
		value = observableValue
		start = startValue
		final = finalValue
		duration = animationDuration
	}

	public convenience init(observableValue: ObservableValue<T>, finalValue: T, animationDuration: Double) {
		self.init(observableValue: observableValue, startValue: observableValue.get(), finalValue: finalValue, animationDuration: animationDuration)
	}

	public override func animate(progress: Double) {

		value.set(start.interpolate(final, progress: progress))
		currentProgress.set(progress)
	}

	public override func getDuration() -> Double {
		return duration
	}
}
