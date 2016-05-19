import Swift_CAAnimation_Closure

public class AnimationProducer {

	let sceneLayer: CALayer

	public required init(layer: CALayer) {
		sceneLayer = layer
	}

	public func addAnimation(animation: Animatable) {
		animation.shape?.animating = true

		switch animation.type {
		case .Unknown:
			return
		case .AffineTransformation:
			addTransformAnimation(animation, sceneLayer: sceneLayer)
		}
	}
}
