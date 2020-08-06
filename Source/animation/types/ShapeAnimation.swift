//
//  ShapeAnimation.swift
//  Pods
//
//  Created by Victor Sukochev on 03/02/2017.
//
//

class ShapeAnimation: AnimationImpl<Shape> {

    convenience init(animatedNode: Shape, finalValue: Shape, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {

        let interpolationFunc = { (t: Double) -> Shape in
            if t == 0 {
                return animatedNode
            }

            return finalValue
        }

        self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
    }

    init(animatedNode: Shape, valueFunc: @escaping (Double) -> Shape, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: AnimatableVariable<Shape>(animatedNode), valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .shape
        node = animatedNode

        if autostart {
            self.play()
        }
    }

    init(animatedNode: Shape, factory: @escaping (() -> ((Double) -> Shape)), animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: AnimatableVariable<Shape>(animatedNode), factory: factory, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .shape
        node = animatedNode

        if autostart {
            self.play()
        }
    }

    // Pause state not available for discreet animation
    override public func pause() {
        stop()
    }

    open override func reverse() -> Animation {
        let factory = { () -> (Double) -> Shape in
            let original = self.timeFactory()
            return { (t: Double) -> Shape in
                original(1.0 - t)
            }
        }

        let reversedAnimation = ShapeAnimation(animatedNode: node as! Shape,
                                               factory: factory,
                                               animationDuration: duration,
                                               fps: logicalFps)
        reversedAnimation.progress = progress
        reversedAnimation.completion = completion

        return reversedAnimation
    }
}

public extension AnimatableVariable where T == Stroke? {

    func animate(from: Stroke? = nil, to: Stroke, during: Double = 1.0, delay: Double = 0.0) {
        let shape = node as! Shape
        shape.stroke = from ?? (shape.stroke ?? Stroke(width: 1.0))
        let finalShape = SceneUtils.shapeCopy(from: shape)
        finalShape.stroke = to
        _ = ShapeAnimation(animatedNode: shape, finalValue: finalShape, animationDuration: during, delay: delay, autostart: true)
    }

    func animation(from: Stroke? = nil, to: Stroke, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        let shape = node as! Shape
        shape.stroke = from ?? (shape.stroke ?? Stroke(width: 1.0))
        let finalShape = SceneUtils.shapeCopy(from: shape)
        finalShape.stroke = to
        return ShapeAnimation(animatedNode: shape, finalValue: finalShape, animationDuration: during, delay: delay, autostart: false)
    }
}
public extension AnimatableVariable where T == Fill? {

    func animate(from: Fill? = nil, to: Fill, during: Double = 1.0, delay: Double = 0.0) {
        let shape = node as! Shape
        shape.fill = from ?? (shape.fill ?? Color.clear)
        let finalShape = SceneUtils.shapeCopy(from: shape)
        finalShape.fill = to
        _ = ShapeAnimation(animatedNode: shape, finalValue: finalShape, animationDuration: during, delay: delay, autostart: true)
    }
    
    func animation(from: Fill? = nil, to: Fill, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        let shape = node as! Shape
        shape.fill = from ?? (shape.fill ?? Color.clear)
        let finalShape = SceneUtils.shapeCopy(from: shape)
        finalShape.fill = to
        return ShapeAnimation(animatedNode: shape, finalValue: finalShape, animationDuration: during, delay: delay, autostart: false)
    }
}
