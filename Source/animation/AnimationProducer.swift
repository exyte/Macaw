import Swift_CAAnimation_Closure

public class AnimationProducer {

	let sceneLayer: CALayer

	public required init(layer: CALayer) {
		sceneLayer = layer
		animationCache.sceneLayer = layer
	}

	public func addAnimation(animation: Animatable) {

		switch animation.type {
		case .Unknown:
			return
		case .AffineTransformation:
			addTransformAnimation(animation, sceneLayer: sceneLayer)

		case .Opacity:
			addOpacityAnimation(animation, sceneLayer: sceneLayer)
		case .Sequence:
			addAnimationSequence(animation)
		case .Combine:
			addCombineAnimation(animation)
		}
	}

	private func addAnimationSequence(animationSequnce: Animatable) {

		guard let sequence = animationSequnce as? AnimationSequence else {
			return
		}

		var timers = [ClosureTimer]()
		sequence.removeFunc = {
			timers.forEach { timer in
				timer.cancel()
			}
		}

		var timeOffset: NSTimeInterval = 0.0

		sequence.animations.forEach { animation in

			let timer = ClosureTimer(time: timeOffset, closure: {
				self.addAnimation(animation)
			})

			timer.start()
			timeOffset += animation.getDuration()
		}

	}

	private func addCombineAnimation(combineAnimation: Animatable) {
		guard let combine = combineAnimation as? CombineAnimation else {
			return
		}

		combine.removeFunc = {
			combine.animations.forEach { animation in
				animation.removeFunc?()
			}
		}

		combine.animations.forEach { animation in
			self.addAnimation(animation)
		}
	}
}
