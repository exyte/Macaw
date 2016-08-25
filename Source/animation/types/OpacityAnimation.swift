
import RxSwift

public class OpacityAnimation: Animation<Double> {

	public convenience init(animatedNode: Node, startValue: Double, finalValue: Double, animationDuration: Double, autostart: Bool = false, fps: UInt = 30) {

		let interpolationFunc = { (t: Double) -> Double in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, autostart: autostart, fps: fps)
	}

	public init(animatedNode: Node, valueFunc: (Double) -> Double, animationDuration: Double, autostart: Bool = false, fps: UInt = 30) {
		super.init(observableValue: animatedNode.opacityVar, valueFunc: valueFunc, animationDuration: animationDuration, autostart: autostart, fps: fps)
		type = .Opacity
		node = animatedNode
	}
}

public typealias OpacityAnimationDescription = AnimationDescription<Double>

public extension AnimatableVariable {
	public func animate(desc: OpacityAnimationDescription) {
		guard let node = self.node else {
			return
		}

		let _ = OpacityAnimation(animatedNode: node, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
	}

	public func animation(desc: OpacityAnimationDescription) -> Animatable {
		guard let node = self.node else {
			return EmptyAnimation(completion: { })
		}

		return OpacityAnimation(animatedNode: node, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
	}

	public func animate(from: Double, to: Double, during: Double) {
		self.animate((from >> to).t(during))
	}

	public func animation(from: Double, to: Double, during: Double) -> Animatable {
		return self.animation((from >> to).t(during))
	}

}