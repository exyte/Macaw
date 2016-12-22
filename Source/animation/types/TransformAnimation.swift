
internal class TransformAnimation: AnimationImpl<Transform> {

	convenience init(animatedNode: Node, startValue: Transform, finalValue: Transform, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {

		let interpolationFunc = { (t: Double) -> Transform in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
	}

	init(animatedNode: Node, valueFunc: @escaping (Double) -> Transform, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
		super.init(observableValue: animatedNode.placeVar, valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
		type = .affineTransformation
		node = animatedNode

		if autostart {
			self.play()
		}
	}
    
    init(animatedNode: Node, factory: @escaping (() -> ((Double) -> Transform)), animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.placeVar, factory: factory, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .affineTransformation
        node = animatedNode
        
        if autostart {
            self.play()
        }
    }

	open override func reverse() -> Animation {

        let factory = { () -> (Double) -> Transform in
            let original = self.timeFactory()
            return { (t: Double) -> Transform in
                return original(1.0 - t)
            }
        }

		let reversedAnimation = TransformAnimation(animatedNode: node!,
			factory: factory, animationDuration: duration, fps: logicalFps)
		reversedAnimation.progress = progress
		reversedAnimation.completion = completion

		return reversedAnimation
	}
}

public typealias TransformAnimationDescription = AnimationDescription<Transform>

public extension AnimatableVariable where T: TransformInterpolation {
	public func animate(_ desc: TransformAnimationDescription) {
		let _ = TransformAnimation(animatedNode: node!, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: true)
	}

	public func animation(_ desc: TransformAnimationDescription) -> Animation {
		return TransformAnimation(animatedNode: node!, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: false)
	}

	public func animate(from: Transform? = nil, to: Transform, during: Double = 1.0, delay: Double = 0.0) {
		self.animate(((from ?? node!.place) >> to).t(during, delay: delay))
	}

	public func animation(from: Transform? = nil, to: Transform, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        if let safeFrom = from {
            return self.animation((safeFrom >> to).t(during, delay: delay))
        }
        
        let origin = node!.place
        let factory = { () -> (Double) -> Transform in
            return { (t: Double) in return origin.interpolate(to, progress: t) }
        }
        return TransformAnimation(animatedNode: self.node!, factory: factory, animationDuration: during, delay: delay)
	}

	public func animation(_ f: @escaping (Double) -> Transform, during: Double, delay: Double = 0.0) -> Animation {
		return TransformAnimation(animatedNode: node!, valueFunc: f, animationDuration: during, delay: delay)
	}

}
