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
                return Shape(form: animatedNode.form,
                             fill: animatedNode.fill,
                             stroke: animatedNode.stroke,
                             place: animatedNode.place,
                             opaque: animatedNode.opaque,
                             opacity: animatedNode.opacity,
                             clip: animatedNode.clip,
                             effect: animatedNode.effect,
                             visible: animatedNode.visible,
                             tag: animatedNode.tag)
            }

            return finalValue
        }

        self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
    }

    init(animatedNode: Shape, valueFunc: @escaping (Double) -> Shape, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: AnimatableVariable<Shape>(animatedNode), valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .shape
        nodeId = animatedNode.id

        if autostart {
            self.play()
        }
    }

    init(animatedNode: Shape, factory: @escaping (() -> ((Double) -> Shape)), animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: AnimatableVariable<Shape>(animatedNode), factory: factory, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .shape
        nodeId = animatedNode.id

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
                return original(1.0 - t)
            }
        }

        let node = Node.nodeBy(id: nodeId!)
        let reversedAnimation = ShapeAnimation(animatedNode: node as! Shape,
                                               factory: factory,
                                               animationDuration: duration,
                                               fps: logicalFps)
        reversedAnimation.progress = progress
        reversedAnimation.completion = completion

        return reversedAnimation
    }
}

public extension AnimatableVariable {
    public func animate<T: Stroke>(from: T? = nil, to: T, during: Double = 1.0, delay: Double = 0.0) {
        let shape = node as! Shape

        var safeFrom = from
        if safeFrom == nil {
            if let shapeStroke = shape.stroke as? T {
                safeFrom = shapeStroke
            } else {
                safeFrom = Stroke(width: 1.0) as? T
            }
        }

        shape.stroke = safeFrom

        let finalShape = SceneUtils.shapeCopy(from: shape)
        finalShape.stroke = to

        _ = ShapeAnimation(animatedNode: shape, finalValue: finalShape, animationDuration: during, delay: delay, autostart: true)
    }

    public func animation<T: Stroke>(from: T? = nil, to: T, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        let shape = node as! Shape

        var safeFrom = from
        if safeFrom == nil {
            if let shapeStroke = shape.stroke as? T {
                safeFrom = shapeStroke
            } else {
                safeFrom = Stroke(width: 1.0) as? T
            }
        }

        shape.stroke = safeFrom

        let finalShape = SceneUtils.shapeCopy(from: shape)
        finalShape.stroke = to

        return ShapeAnimation(animatedNode: shape, finalValue: finalShape, animationDuration: during, delay: delay, autostart: false)
    }
}

public extension AnimatableVariable {
    public func animate<T: Fill>(from: T? = nil, to: T, during: Double = 1.0, delay: Double = 0.0) {
        let shape = node as! Shape

        var safeFrom = from
        if safeFrom == nil {
            if let shapeFill = shape.fill as? T {
                safeFrom = shapeFill
            } else {
                safeFrom = Color.clear as? T
            }
        }

        shape.fill = safeFrom

        let finalShape = SceneUtils.shapeCopy(from: shape)
        finalShape.fill = to

        _ = ShapeAnimation(animatedNode: shape, finalValue: finalShape, animationDuration: during, delay: delay, autostart: true)
    }

    public func animation<T: Fill>(from: T? = nil, to: T, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        let shape = node as! Shape

        var safeFrom = from
        if safeFrom == nil {
            if let shapeFill = shape.fill as? T {
                safeFrom = shapeFill
            } else {
                safeFrom = Color.clear as? T
            }
        }

        shape.fill = safeFrom

        let finalShape = SceneUtils.shapeCopy(from: shape)
        finalShape.fill = to

        return ShapeAnimation(animatedNode: shape, finalValue: finalShape, animationDuration: during, delay: delay, autostart: false)
    }
}
