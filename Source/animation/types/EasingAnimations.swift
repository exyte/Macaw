import Foundation

// good math reference: http://gizma.com/easing/

public extension Animatable {
    public func easeIn() -> Animatable {
        return EaseInAnimation(animation: self)
    }
    
    public func easeOut() -> Animatable {
        return EaseOutAnimation(animation: self)
    }
}

public class EaseInAnimation: Animatable {
    let originalAnimation: Animatable
    
    public required init(animation: Animatable) {
        originalAnimation = animation
    }
    
    public override func animate(progress: Double) {
        originalAnimation.animate(pow(progress, 2.0))
    }
    
    public override func getDuration() -> Double {
        return originalAnimation.getDuration()
    }
}

public class EaseOutAnimation: Animatable {
    let originalAnimation: Animatable
    
    public required init(animation: Animatable) {
        originalAnimation = animation
    }
    
    public override func animate(progress: Double) {
        originalAnimation.animate(pow(progress, 0.5))
    }
    
    public override func getDuration() -> Double {
        return originalAnimation.getDuration()
    }
}