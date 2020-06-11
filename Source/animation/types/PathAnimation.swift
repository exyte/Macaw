//
//  PathAnimation.swift
//  Macaw
//
//  Created by Victor Sukochev on 01/01/2018.
//

import Foundation

class PathAnimation: AnimationImpl<StrokeEnd> {

    convenience init(animatedNode: Shape, startValue: StrokeEnd, finalValue: StrokeEnd, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {

        let interpolationFunc = { (t: Double) -> StrokeEnd in
            startValue.interpolate(finalValue, progress: t)
        }

        self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
    }

    init(animatedNode: Shape, valueFunc: @escaping (Double) -> StrokeEnd, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.strokeEndVar, valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .path
        node = animatedNode

        if autostart {
            self.play()
        }
    }

    init(animatedNode: Shape, factory: @escaping (() -> ((Double) -> StrokeEnd)), animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.strokeEndVar, factory: factory, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .path
        node = animatedNode

        if autostart {
            self.play()
        }
    }

    // Pause state not available for discreet animation
    override public func pause() {
        stop()
    }
}

public typealias PathAnimationDescription = AnimationDescription<StrokeEnd>

public extension AnimatableVariable where T: StrokeEndInterpolation {

    func animate(_ desc: PathAnimationDescription) {
        _ = PathAnimation(animatedNode: node as! Shape, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: true)
    }

    func animation(_ desc: PathAnimationDescription) -> Animation {
        return PathAnimation(animatedNode: node as! Shape, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: false)
    }

    func animate(from: StrokeEnd? = nil, to: StrokeEnd, during: Double = 1.0, delay: Double = 0.0) {
        self.animate(((from ?? StrokeEnd.zero) >> to).t(during, delay: delay))
    }

    func animation(from: StrokeEnd? = nil, to: StrokeEnd, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        if let safeFrom = from {
            return self.animation((safeFrom >> to).t(during, delay: delay))
        }
        let origin = StrokeEnd.zero
        let factory = { () -> (Double) -> StrokeEnd in
            { (t: Double) in origin.interpolate(to, progress: t) }
        }
        return PathAnimation(animatedNode: node as! Shape, factory: factory, animationDuration: during, delay: delay)
    }

    func animation(_ f: @escaping ((Double) -> StrokeEnd), during: Double = 1.0, delay: Double = 0.0) -> Animation {
        return PathAnimation(animatedNode: node as! Shape, valueFunc: f, animationDuration: during, delay: delay)
    }
}
