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
}

// public typealias StrokeAnimationDescription = AnimationDescription<Stroke?>

public extension AnimatableVariable {
    public func animate<T:Stroke>(from: T? = nil, to: T, during: Double = 1.0, delay: Double = 0.0) {
        var shape = node as! Shape
        
        var safeFrom = from
        if safeFrom == nil {
            safeFrom =  shape.stroke as! T
        }
        
        shape.stroke = safeFrom
        
        let finalShape = Shape(form: shape.form,
                               fill: shape.fill,
                               stroke: to,
                               place: shape.place,
                               opaque: shape.opaque,
                               opacity: shape.opacity,
                               clip: shape.clip,
                               effect: shape.effect,
                               visible: shape.visible,
                               tag: shape.tag)
        
        let _ = ShapeAnimation(animatedNode: shape, finalValue: finalShape, animationDuration: during, delay: delay, autostart: true)
    }
    
    public func animation<T:Stroke>(from: T? = nil, to: T, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        var shape = node as! Shape
        
        var safeFrom = from
        if safeFrom == nil {
            safeFrom =  shape.stroke as! T
        }
        
        shape.stroke = safeFrom
        
        let finalShape = Shape(form: shape.form,
                               fill: shape.fill,
                               stroke: to,
                               place: shape.place,
                               opaque: shape.opaque,
                               opacity: shape.opacity,
                               clip: shape.clip,
                               effect: shape.effect,
                               visible: shape.visible,
                               tag: shape.tag)
        
        return ShapeAnimation(animatedNode: shape, finalValue: finalShape, animationDuration: during, delay: delay, autostart: false)
    }
}
