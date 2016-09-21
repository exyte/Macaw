import RxSwift

internal class TransformAnimation: AnimationImpl<Transform> {

	convenience init(animatedNode: Node, startValue: Transform, finalValue: Transform, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {

		let interpolationFunc = { (t: Double) -> Transform in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
	}

	init(animatedNode: Node, valueFunc: (Double) -> Transform, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
		super.init(observableValue: animatedNode.placeVar, valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
		type = .AffineTransformation
		node = animatedNode

		if autostart {
			self.play()
		}
	}

	public override func reverse() -> Animation {

		let reversedFunc = { (t: Double) -> Transform in
			return self.vFunc(1.0 - t)
		}

		let reversedAnimation = TransformAnimation(animatedNode: node!,
			valueFunc: reversedFunc, animationDuration: duration, fps: logicalFps)
		reversedAnimation.progress = progress
		reversedAnimation.completion = completion

		return reversedAnimation
	}
}

public typealias TransformAnimationDescription = AnimationDescription<Transform>

public extension AnimatableVariable where T: TransformInterpolation {
	public func animate(desc: TransformAnimationDescription) {
		guard let node = self.node else {
			return
		}

		let _ = TransformAnimation(animatedNode: node, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: true)
	}

	public func animation(desc: TransformAnimationDescription) -> Animation {
		guard let node = self.node else {
			return EmptyAnimation(completion: { })
		}

		return TransformAnimation(animatedNode: node, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: false)
	}

	public func animate(from from: Transform? = nil, to: Transform, during: Double, delay: Double = 0.0) {
		self.animate(((from ?? node!.place) >> to).t(during, delay: delay))
	}

	public func animation(from from: Transform, to: Transform, during: Double, delay: Double = 0.0) -> Animation {
		return self.animation((from >> to).t(during, delay: delay))
	}

	public func animation(valueFunc valueFrunc: (Double) -> Transform, during: Double, delay: Double = 0.0) -> Animation {
		guard let node = self.node else {
			return EmptyAnimation(completion: { })
		}

		return TransformAnimation(animatedNode: node, valueFunc: valueFrunc, animationDuration: during, delay: delay)
	}

}
