import Foundation

public extension SequenceType where Generator.Element: Animatable {
	public func animationSequence() -> Animatable {
		let sequence = AnimationSequence(animations: [])
		self.forEach { animation in
			sequence.addAnimation(animation)
		}

		return sequence
	}
}

public class AnimationSequence: Animatable {

	var sequence: [Animatable] = []

	public required init(animations: [Animatable]) {
		sequence.appendContentsOf(animations)
	}

	public convenience init(animation: Animatable) {
		self.init(animations: [animation])
	}

	public func addAnimation(animation: Animatable) {
		sequence.append(animation)
	}

	public override func animate(progress: Double) {
		var progressOffset = 0.0
		let totalDuration = getDuration()
		for animation in sequence {

			let prevOffset = progressOffset
			let interval = animation.getDuration() / totalDuration
			progressOffset = progressOffset + interval

			if progress < prevOffset {
				continue
			}

			if progress > progressOffset {
				continue
			}

			let relativeProgress = (progress - prevOffset) / interval
			animation.animate(relativeProgress)
			break
		}
	}

	public override func getDuration() -> Double {
		return sequence.map { $0.getDuration() }.reduce(0, combine: +)
	}
}
