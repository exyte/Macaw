//
//  PathAnimation.swift
//  Macaw
//
//  Created by Victor Sukochev on 01/01/2018.
//

import Foundation

class PathAnimation: AnimationImpl<Double> {

    let isEnd: Bool = true

    convenience init(animatedNode: Shape, isEnd: Bool, startValue: Double, finalValue: Double, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {

        let interpolationFunc = { (t: Double) -> Double in
            startValue.interpolate(finalValue, progress: t)
        }

        self.init(animatedNode: animatedNode, isEnd: isEnd, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
    }

    init(animatedNode: Shape, isEnd: Bool, valueFunc: @escaping (Double) -> Double, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: AnimatableVariable<Double>(isEnd ? animatedNode.strokeVar.end.value : animatedNode.strokeVar.start.value), valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .path
        node = animatedNode

        if autostart {
            self.play()
        }
    }

    init(animatedNode: Shape, isEnd: Bool, factory: @escaping (() -> ((Double) -> Double)), animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: AnimatableVariable<Double>(isEnd ? animatedNode.strokeVar.end.value : animatedNode.strokeVar.start.value), factory: factory, animationDuration: animationDuration, delay: delay, fps: fps)
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

public typealias PathAnimationDescription = AnimationDescription<Double>

open class StrokeAnimatableVariable: AnimatableVariable<Stroke?> {

    public var end: StrokeSideVariable {
        return StrokeSideVariable(parentVar: self, isEnd: true)
    }

    public var start: StrokeSideVariable {
        return StrokeSideVariable(parentVar: self, isEnd: false)
    }
}

open class StrokeSideVariable {

    let parentVar: StrokeAnimatableVariable
    let isEnd: Bool
    var value: Double = 0

    var node: Node? {
        parentVar.node
    }

    init(parentVar: StrokeAnimatableVariable, isEnd: Bool, value: Double = 0) {
        self.parentVar = parentVar
        self.isEnd = isEnd
        self.value = value
    }

    public func animate(_ desc: PathAnimationDescription) {
        _ = PathAnimation(animatedNode: node as! Shape, isEnd: isEnd, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: true)
    }

    public func animation(_ desc: PathAnimationDescription) -> Animation {
        return PathAnimation(animatedNode: node as! Shape, isEnd: isEnd, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: false)
    }

    public func animate(from: Double? = nil, to: Double = 1, during: Double = 1.0, delay: Double = 0.0) {
        self.animate(((from ?? 0) >> to).t(during, delay: delay))
    }

    public func animation(from: Double? = nil, to: Double = 1, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        if let safeFrom = from {
            return self.animation((safeFrom >> to).t(during, delay: delay))
        }
        let origin = Double(0)
        let factory = { () -> (Double) -> Double in
            { (t: Double) in origin.interpolate(to, progress: t) }
        }
        return PathAnimation(animatedNode: node as! Shape, isEnd: isEnd, factory: factory, animationDuration: during, delay: delay)
    }

    public func animation(_ f: @escaping ((Double) -> Double), during: Double = 1.0, delay: Double = 0.0) -> Animation {
        return PathAnimation(animatedNode: node as! Shape, isEnd: isEnd, valueFunc: f, animationDuration: during, delay: delay)
    }
}
