import Foundation
import QuartzCore

class AnimationLoop {

	var displayLink: CADisplayLink?

	var animationSubscriptions: [AnimationSubscription] = []
	var rendererCall: (() -> ())?

	init() {
		displayLink = CADisplayLink(target: self, selector: #selector(onFrameUpdate(_:)))
		displayLink?.paused = false
		displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
	}

	dynamic private func onFrameUpdate(displayLink: CADisplayLink) {

		var toRemove = [AnimationSubscription]()
		let timestamp = displayLink.timestamp

		animationSubscriptions.forEach { subscription in

			// Handle manually set position
			if !subscription.anim.paused {
				if let pausedPosition = subscription.anim.currentProgress {
					subscription.anim.currentProgress = .None
					subscription.startTime = timestamp - subscription.anim.getDuration() * pausedPosition
					subscription.moveToTimeFrame(pausedPosition)
					return
				}
			}

			// Calculating current position
			if subscription.startTime == .None {
				subscription.startTime = timestamp
			}

			guard let startTime = subscription.startTime else {
				return
			}

			let timePosition = timestamp - startTime
			let position = timePosition / subscription.anim.getDuration()

			if subscription.anim.shouldBeRemoved {
				toRemove.append(subscription)
			}

			// Saving paused position
			if subscription.anim.paused {
				if subscription.anim.currentProgress == .None {
					subscription.anim.currentProgress = position
				}

				return
			}

			subscription.moveToTimeFrame(position)
		}

		rendererCall?()

		// Removing
		toRemove.forEach { subsription in
			if let index = animationSubscriptions.indexOf({ $0 === subsription }) {
				animationSubscriptions.removeAtIndex(index)
			}
		}
	}

	func renderManually() {
		guard let timestamp = displayLink?.timestamp else {
			return
		}

		animationSubscriptions.forEach { subscription in

			// Handle manually set position
			guard let pausedPosition = subscription.anim.currentProgress else {
				return
			}

			subscription.startTime = timestamp - subscription.anim.getDuration() * pausedPosition
			subscription.moveToTimeFrame(pausedPosition)
		}

		rendererCall?()
	}
}
