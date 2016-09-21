
import RxSwift

internal class OpacityAnimation: AnimationImpl<Double> {

	convenience init(animatedNode: Node, startValue: Double, finalValue: Double, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {

		let interpolationFunc = { (t: Double) -> Double in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
	}

	init(animatedNode: Node, valueFunc: (Double) -> Double, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
		super.init(observableValue: animatedNode.opacityVar, valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
		type = .Opacity
		node = animatedNode

		if autostart {
			self.play()
		}
	}

	public override func reverse() -> Animation {

		let reversedFunc = { (t: Double) -> Double in
			return self.vFunc(1.0 - t)
		}

		let reversedAnimation = OpacityAnimation(animatedNode: node!,
			valueFunc: reversedFunc, animationDuration: duration, fps: logicalFps)
		reversedAnimation.progress = progress
		reversedAnimation.completion = completion

		return reversedAnimation
	}
}

public typealias OpacityAnimationDescription = AnimationDescription<Double>

public extension AnimatableVariable where T: DoubleInterpolation  {
   // public func animate(desc: AnimationDescription<T: Double>) {
	public func animate(desc: OpacityAnimationDescription) {
		guard let node = self.node else {
			return
		}

		let _ = OpacityAnimation(animatedNode: node, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: true)
	}

    public func animation(desc: OpacityAnimationDescription) -> Animation {
		guard let node = self.node else {
			return EmptyAnimation(completion: { })
		}

		return OpacityAnimation(animatedNode: node, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: false)
	}

	public func animate(from from: Double, to: Double, during: Double, delay: Double = 0.0) {
		self.animate((from >> to).t(during, delay: delay))
	}

	public func animation(from from: Double, to: Double, during: Double, delay: Double = 0.0) -> Animation {
		return self.animation((from >> to).t(during, delay: delay))
	}

	public func animation(valueFunc valueFrunc: (Double) -> Double, during: Double, delay: Double = 0.0) -> Animation {
		guard let node = self.node else {
			return EmptyAnimation(completion: { })
		}

		return OpacityAnimation(animatedNode: node, valueFunc: valueFrunc, animationDuration: during, delay: delay)
	}

}
