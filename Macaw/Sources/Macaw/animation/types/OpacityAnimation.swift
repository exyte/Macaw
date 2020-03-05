internal class OpacityAnimation: AnimationImpl<Double> {

    convenience init(animatedNode: Node, startValue: Double, finalValue: Double, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {

        let interpolationFunc = { (t: Double) -> Double in
            startValue.interpolate(finalValue, progress: t)
        }

        self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
    }

    init(animatedNode: Node, valueFunc: @escaping (Double) -> Double, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.opacityVar, valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .opacity
        node = animatedNode

        if autostart {
            self.play()
        }
    }

    init(animatedNode: Node, factory: @escaping  (() -> ((Double) -> Double)), animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.opacityVar, factory: factory, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .opacity
        node = animatedNode

        if autostart {
            self.play()
        }
    }

    open override func reverse() -> Animation {
        let factory = { () -> (Double) -> Double in
            let original = self.timeFactory()
            return { (t: Double) -> Double in
                original(1.0 - t)
            }
        }

        let reversedAnimation = OpacityAnimation(animatedNode: node!,
                                                 factory: factory, animationDuration: duration, fps: logicalFps)
        reversedAnimation.progress = progress
        reversedAnimation.completion = completion

        return reversedAnimation
    }
}

public typealias OpacityAnimationDescription = AnimationDescription<Double>

public extension AnimatableVariable where T: DoubleInterpolation {
    func animate(_ desc: OpacityAnimationDescription) {
        _ = OpacityAnimation(animatedNode: node!, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: true)
    }

    func animation(_ desc: OpacityAnimationDescription) -> Animation {
        return OpacityAnimation(animatedNode: node!, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: false)
    }

    func animate(from: Double? = nil, to: Double, during: Double = 1.0, delay: Double = 0.0) {
        self.animate(((from ?? node!.opacity) >> to).t(during, delay: delay))
    }

    func animation(from: Double? = nil, to: Double, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        if let safeFrom = from {
            return self.animation((safeFrom >> to).t(during, delay: delay))
        }
        let origin = node!.opacity
        let factory = { () -> (Double) -> Double in { (t: Double) in origin.interpolate(to, progress: t) }
        }
        return OpacityAnimation(animatedNode: self.node!, factory: factory, animationDuration: during, delay: delay)
    }

    func animation(_ f: @escaping ((Double) -> Double), during: Double = 1.0, delay: Double = 0.0) -> Animation {
        return OpacityAnimation(animatedNode: node!, valueFunc: f, animationDuration: during, delay: delay)
    }

}
