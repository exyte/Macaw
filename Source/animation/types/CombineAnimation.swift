
import Foundation

internal class CombineAnimation: Animation {

	let animations: [Animation]

	required init(animations: [Animation]) {
		self.animations = animations

		super.init()

		type = .Combine
		self.node = animations.first?.node

	}

	override func getDuration() -> Double {
		if let maxElement = animations.map({ $0.getDuration() }).maxElement() {
			return maxElement
		}

		return 0.0
	}

	public override func reverse() -> Animation {
		var reversedAnimations = [Animation]()
		animations.forEach { animation in
			reversedAnimations.append(animation.reverse())
		}

		let combineReversed = reversedAnimations.combine()
		combineReversed.completion = completion
		combineReversed.progress = progress

		return combineReversed
	}

	public override func stop() {
		animations.forEach { animation in
			animation.stop()
		}
	}
}

public extension SequenceType where Generator.Element: Animation {
	public func combine() -> Animation {

		var toCombine = [Animation]()
		self.forEach { animation in
			toCombine.append(animation)
		}
		return CombineAnimation(animations: toCombine)
	}
}