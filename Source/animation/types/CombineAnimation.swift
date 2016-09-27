
import Foundation

internal class CombineAnimation: BasicAnimation {

	let animations: [BasicAnimation]

	required init(animations: [BasicAnimation], delay: Double = 0.0) {
		self.animations = animations

		super.init()

		self.type = .combine
		self.node = animations.first?.node
		self.delay = delay

	}

	override func getDuration() -> Double {
		if let maxElement = animations.map({ $0.getDuration() }).max() {
			return maxElement
		}

		return 0.0
	}

	open override func reverse() -> Animation {
		var reversedAnimations = [BasicAnimation]()
		animations.forEach { animation in
			reversedAnimations.append(animation.reverse() as! BasicAnimation)
		}

		let combineReversed = reversedAnimations.combine(delay: self.delay) as! BasicAnimation
		combineReversed.completion = completion
		combineReversed.progress = progress

		return combineReversed
	}

	open override func stop() {
		animations.forEach { animation in
			animation.stop()
		}
	}
}

public extension Sequence where Iterator.Element: Animation {
	public func combine(delay: Double = 0.0) -> Animation {

		var toCombine = [BasicAnimation]()
		self.forEach { animation in
			toCombine.append(animation as! BasicAnimation)
		}
		return CombineAnimation(animations: toCombine, delay: delay)
	}
}
