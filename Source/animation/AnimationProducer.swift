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
		}
	}
}
