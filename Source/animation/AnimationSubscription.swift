import Foundation

class AnimationSubscription {

	let anim: Animatable

	var startTime: CFTimeInterval?

	init(animation: Animatable, paused: Bool = false) {
		anim = animation
		anim.paused = paused
	}

	func  moveToTimeFrame(position: Double) {
		anim.animate(position)
	}
}
