import Swift_CAAnimation_Closure

class AnimationProducer {

	let sceneLayer: CALayer
	let animationCache: AnimationCache

	required init(layer: CALayer, animationCache: AnimationCache) {
		self.sceneLayer = layer
		self.animationCache = animationCache
		animationCache.sceneLayer = layer
	}

	public func addAnimation(animation: Animatable) {

		switch animation.type {
		case .Unknown:
			return
		case .AffineTransformation:
			addTransformAnimation(animation, sceneLayer: sceneLayer, animationCache: animationCache)

		case .Opacity:
			addOpacityAnimation(animation, sceneLayer: sceneLayer, animationCache: animationCache)
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
		sequence.completionTimer?.start()

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

		combine.completionTimer?.start()
	}
}
