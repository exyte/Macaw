
class MorphingAnimation:  AnimationImpl<Locus> {
    
    convenience init(animatedNode: Shape, startValue: Locus, finalValue: Locus, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        
        let interpolationFunc = { (t: Double) -> Locus in
            return finalValue//startValue.interpolate(finalValue, progress: t)
        }
        
        self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
    }
    
    init(animatedNode: Shape, valueFunc: @escaping (Double) -> Locus, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.formVar, valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .morphing
        node = animatedNode
        
        if autostart {
            self.play()
        }
    }
    
    init(animatedNode: Shape, factory: @escaping (() -> ((Double) -> Locus)), animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.formVar, factory: factory, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .morphing
        node = animatedNode
        
        if autostart {
            self.play()
        }
    }
}

public typealias MorphingAnimationDescription = AnimationDescription<Locus>

public extension AnimatableVariable where T: MorphingAnimationDescription {
    public func animate(_ desc: MorphingAnimationDescription) {
        let _ = MorphingAnimation(animatedNode: node as! Shape, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: true)
    }
    
    public func animation(_ desc: MorphingAnimationDescription) -> Animation {
                return MorphingAnimation(animatedNode: node as! Shape, valueFunc: desc.valueFunc, animationDuration: desc.duration, delay: desc.delay, autostart: false)
    }
    
    public func animate(from: Locus? =
        nil, to: Locus, during: Double = 1.0, delay: Double = 0.0) {
        self.animate(((from ?? (node as! Shape).form) >> to).t(during, delay: delay))
    }
    
    public func animation(from: Locus? = nil, to: Locus, during: Double = 1.0, delay: Double = 0.0) -> Animation {
        if let safeFrom = from {
            return self.animation((safeFrom >> to).t(during, delay: delay))
        }
        
        let origin = (node as! Shape).form
        let factory = { () -> (Double) -> Locus in
            return { (t: Double) in return to }//origin.interpolate(to, progress: t) }
        }

        return MorphingAnimation(animatedNode: self.node as! Shape, factory: factory, animationDuration: during, delay: delay)
    }
    
    public func animation(_ f: @escaping (Double) -> Locus, during: Double, delay: Double = 0.0) -> Animation {
        return MorphingAnimation(animatedNode: node as! Shape, valueFunc: f, animationDuration: during, delay: delay)
    }
    
}
