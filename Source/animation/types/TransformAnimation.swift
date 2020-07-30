import Foundation

internal class TransformAnimation: AnimationImpl<Transform> {

    var trajectory: Path?

    convenience init(animatedNode: Node, startValue: Transform, finalValue: Transform, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {

        let interpolationFunc = { (t: Double) -> Transform in
            startValue.interpolate(finalValue, progress: t)
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

    init(animatedNode: Node, factory: @escaping (() -> ((Double) -> Transform)), along path: Path, animationDuration: Double = 1.0, delay: Double = 0.0, autostart: Bool = false) {
        super.init(observableValue: animatedNode.placeVar, factory: factory, animationDuration: animationDuration, delay: delay)
        type = .affineTransformation
        node = animatedNode
        self.trajectory = path

        if autostart {
            self.play()
        }
    }

    open override func reverse() -> Animation {

        let factory = { () -> (Double) -> Transform in
            let original = self.timeFactory()
            return { (t: Double) -> Transform in
                original(1.0 - t)
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
    func animate(_ desc: TransformAnimationDescription) {
        _ = TransformAnimation(animatedNode: node!, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: true)
    }

    func animation(_ desc: TransformAnimationDescription) -> Animation {
        return TransformAnimation(animatedNode: node!, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: false)
    }

    func animate(from: Transform? = nil, to: Transform, during: Double = 1.0, delay: Double = 0.0) {
        self.animate(((from ?? node!.place) >> to).t(during, delay: delay))
    }

    func animate(angle: Double, x: Double? = .none, y: Double? = .none, during: Double = 1.0, delay: Double = 0.0) {
        let animation = self.animation(angle: angle, x: x, y: y, during: during, delay: delay)
        animation.play()
    }

    func animate(along path: Path, during: Double = 1.0, delay: Double = 0.0) {
        let animation = self.animation(along: path, during: during, delay: delay)
        animation.play()
    }

    func animation(from: Transform? = nil, to: Transform, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        if let safeFrom = from {
            return self.animation((safeFrom >> to).t(during, delay: delay))
        }

        let origin = node!.place
        let factory = { () -> (Double) -> Transform in { (t: Double) in origin.interpolate(to, progress: t) }
        }
        return TransformAnimation(animatedNode: self.node!, factory: factory, animationDuration: during, delay: delay)
    }

    func animation(_ f: @escaping ((Double) -> Transform), during: Double = 1.0, delay: Double = 0.0) -> Animation {
        return TransformAnimation(animatedNode: node!, valueFunc: f, animationDuration: during, delay: delay)
    }

    func animation(angle: Double, x: Double? = .none, y: Double? = .none, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        let bounds = node!.bounds!
        let place = node!.place

        let factory = { () -> (Double) -> Transform in { t in
            let asin = sin(angle * t); let acos = cos(angle * t)

            let rotation = Transform(
                m11: acos, m12: -asin,
                m21: asin, m22: acos
            )

            let move = Transform.move(
                dx: x ?? bounds.x + bounds.w / 2.0,
                dy: y ?? bounds.y + bounds.h / 2.0
            )

            return place.concat(with: move).concat(with: rotation).concat(with: move.invert()!)
        }
        }

        return TransformAnimation(animatedNode: node!, factory: factory, animationDuration: during, delay: delay)
    }

    func animation(along path: Path, during: Double = 1.0, delay: Double = 0.0) -> Animation {

        let factory = { () -> (Double) -> Transform in { (t: Double) in self.node?.place ?? .identity }
        }
        return TransformAnimation(animatedNode: self.node!, factory: factory, along: path, animationDuration: during, delay: delay)
    }

}
