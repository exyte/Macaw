
import Foundation

public class AnimationSequence: Animatable {

	let animations: [Animatable]

	required public init(animations: [Animatable]) {
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
}

public extension SequenceType where Generator.Element: Animatable {
	public func sequence() -> Animatable {

		var sequence = [Animatable]()
		self.forEach { animation in
			sequence.append(animation)
		}
		return AnimationSequence(animations: sequence)
	}
}
