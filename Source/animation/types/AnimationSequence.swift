
import Foundation

internal class AnimationSequence: BasicAnimation {

	let animations: [BasicAnimation]

	required init(animations: [BasicAnimation], delay: Double = 0.0) {
		self.animations = animations

		super.init()

		self.type = .sequence
		self.node = animations.first?.node
		self.delay = delay
	}

	override func getDuration() -> Double {
		return animations.map({ $0.getDuration() }).reduce(0, { $0 + $1 })
	}

	open override func stop() {
		animations.forEach { animation in
			animation.stop()
		}
	}

	open override func reverse() -> Animation {
		var reversedAnimations = [BasicAnimation]()
		animations.forEach { animation in
			reversedAnimations.append(animation.reverse() as! BasicAnimation)
		}

		let reversedSequence = reversedAnimations.reversed().sequence(delay: self.delay) as! BasicAnimation
		reversedSequence.completion = completion
		reversedSequence.progress = progress

		return reversedSequence
	}
}

public extension Sequence where Iterator.Element: Animation {
	public func sequence(delay: Double = 0.0) -> Animation {

		var sequence = [BasicAnimation]()
		self.forEach { animation in
			sequence.append(animation as! BasicAnimation)
		}
		return AnimationSequence(animations: sequence, delay: delay)
	}
}
