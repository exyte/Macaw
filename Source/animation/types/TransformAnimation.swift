import RxSwift

public class TransformAnimation: Animation<Transform> {

	public convenience init(animatedNode: Node, startValue: Transform, finalValue: Transform, animationDuration: Double, autostart: Bool = false, fps: UInt = 30) {

		let interpolationFunc = { (t: Double) -> Transform in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, autostart: autostart, fps: fps)
	}

	public init(animatedNode: Node, valueFunc: (Double) -> Transform, animationDuration: Double, autostart: Bool = false, fps: UInt = 30) {
		super.init(observableValue: animatedNode.posVar, valueFunc: valueFunc, animationDuration: animationDuration, fps: fps)
		type = .AffineTransformation
		node = animatedNode
	}
}

public typealias TransformAnimationDescription = AnimationDescription<Transform>

public extension AnimatableVariable {
	public func animate(desc: TransformAnimationDescription) {
		guard let node = self.node else {
			return
		}

		let _ = TransformAnimation(animatedNode: node, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
	}

	public func animation(desc: TransformAnimationDescription) -> Animatable {
		guard let node = self.node else {
			return EmptyAnimation(completion: { })
		}

		return TransformAnimation(animatedNode: node, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
	}

	public func animate(from: Transform, to: Transform, during: Double) {
		self.animate((from >> to).t(during))
	}

	public func animation(from: Transform, to: Transform, during: Double) -> Animatable {
		return self.animation((from >> to).t(during))
	}

}
