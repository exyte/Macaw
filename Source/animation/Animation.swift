import Foundation

public extension SequenceType where Generator.Element: Animatable {
	func play() {
		self.forEach { animation in
			animation.play()
		}
	}

	func pause() {
		self.forEach { animation in
			animation.pause()
		}
	}

	func remove() {
		self.forEach { animation in
			animation.remove()
		}
	}
}

public class Animatable {

	var shouldBeRemoved = false
	var paused = false
	public var currentProgress: Double?

	public var progressCall: ((Double) -> ())?

	func animate(progress: Double) { }
	func getDuration() -> Double { return 0 }

	func play() { paused = false }
	func pause() { paused = true }
	func remove() { shouldBeRemoved = true }
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
		progressCall?(progress)
	}

	public override func getDuration() -> Double {
		return duration
	}
}
