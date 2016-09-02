
import Foundation

internal class CombineAnimation: BasicAnimation {

	let animations: [BasicAnimation]

	required init(animations: [BasicAnimation]) {
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
		var reversedAnimations = [BasicAnimation]()
		animations.forEach { animation in
			reversedAnimations.append(animation.reverse() as! BasicAnimation)
		}

		let combineReversed = reversedAnimations.combine() as! BasicAnimation
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

		var toCombine = [BasicAnimation]()
		self.forEach { animation in
			toCombine.append(animation as! BasicAnimation)
		}
		return CombineAnimation(animations: toCombine)
	}
}