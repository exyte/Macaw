import Foundation
import QuartzCore

class AnimationLoop {

	var displayLink: CADisplayLink?

	private var animationSubscriptions: [AnimationSubscription] = []
	var rendererCall: (() -> ())?

	init() {
		displayLink = CADisplayLink(target: self, selector: #selector(onFrameUpdate(_:)))
		displayLink?.paused = false
		displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
	}

	dynamic private func onFrameUpdate(displayLink: CADisplayLink) {

		let timestamp = displayLink.timestamp

		var toRemove = [AnimationSubscription]()
		var shouldRender = false

		animationSubscriptions.forEach { subscription in

			let animation = subscription.anim

			if animation.paused {
				return
			}

			shouldRender = true

			if animation.shouldUpdateSubscription {
				animation.shouldUpdateSubscription = false
				subscription.startTime = timestamp - animation.getDuration() * animation.currentProgress.get()
			}

			// Calculating current position
			if subscription.startTime == .None {
				subscription.startTime = timestamp
			}

			guard let startTime = subscription.startTime else {
				return
			}

			let timePosition = timestamp - startTime
			let position = timePosition / animation.getDuration()

			if animation.shouldBeRemoved {
				toRemove.append(subscription)
			}

			animation.currentProgress.set(position)
			subscription.moveToTimeFrame(position)
		}

		if shouldRender {
			rendererCall?()
		}

		// Removing
		toRemove.forEach { subsription in
			if let index = animationSubscriptions.indexOf({ $0 === subsription }) {
				animationSubscriptions.removeAtIndex(index)
			}
		}
	}

	func addSubscription(subscription: AnimationSubscription) {
		animationSubscriptions.append(subscription)

		let animation = subscription.anim
		if !animation.paused {
			return
		}

		animation.currentProgress.addListener { (oldValue, newValue) in
			if !subscription.anim.paused {
				return
			}

			subscription.moveToTimeFrame(newValue)
			self.rendererCall?()
		}
	}
}
