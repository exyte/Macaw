
import Foundation

internal class AnimationSequence: Animation {

	let animations: [Animation]

	required init(animations: [Animation]) {
		self.animations = animations

		super.init()

		type = .Sequence
		self.node = animations.first?.node
	}

	override func getDuration() -> Double {
		return animations.map({ $0.getDuration() }).reduce(0, combine: { $0 + $1 })
	}

	public override func stop() {
		animations.forEach { animation in
			animation.stop()
		}
	}

	public override func reverse() -> Animation {
		var reversedAnimations = [Animation]()
		animations.forEach { animation in
			reversedAnimations.append(animation.reverse())
		}

		let reversedSequence = reversedAnimations.reverse().sequence()
		reversedSequence.completion = completion
		reversedSequence.progress = progress

		return reversedSequence
	}
}

public extension SequenceType where Generator.Element: Animation {
	public func sequence() -> Animation {

		var sequence = [Animation]()
		self.forEach { animation in
			sequence.append(animation)
		}
		return AnimationSequence(animations: sequence)
	}
}
