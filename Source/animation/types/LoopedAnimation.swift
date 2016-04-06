import Foundation

public extension Animatable {
	public func looped() -> Animatable {
		return LoopedAnimation(animation: self)
	}
}

public class LoopedAnimation: Animatable {
	let loopedlAnimation: Animatable

	public required init(animation: Animatable) {
		loopedlAnimation = AnimationSequence(animations: [animation, RevertedAnimation(animation: animation)])
	}

	public override func animate(progress: Double) {
		loopedlAnimation.animate(progress)
		progressCall?(progress)
	}

	public override func getDuration() -> Double {
		return loopedlAnimation.getDuration()
	}
}
