import Foundation

public extension Animatable {
	public func revert() -> Animatable {
		return RevertedAnimation(animation: self)
	}
}

public class RevertedAnimation: Animatable {
	let originalAnimation: Animatable

	public required init(animation: Animatable) {
		originalAnimation = animation
	}

	public override func animate(progress: Double) {
		originalAnimation.animate(1.0 - progress)
	}

	public override func getDuration() -> Double {
		return originalAnimation.getDuration()
	}
}
