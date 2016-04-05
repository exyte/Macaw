import Foundation


public enum RepetitiveAnimationType {
    case Finite
    case Infinite
}

public extension Animatable {
    public func infiniteLoop() -> Animatable {
        return RepetitiveAnimation(animation: self)
    }
    
    public func loop(count: Int) -> Animatable {
        return RepetitiveAnimation(animation: self, count: count)
    }
}

public class RepetitiveAnimation: Animatable {
    
    let loopAnimation: Animatable
    var loopsCount: Int
    
    public required init(animation: Animatable, type: RepetitiveAnimationType, count: Int) {
        loopAnimation = animation
        loopsCount    = count
        
        if type == .Infinite {
            loopsCount = Int.max
        }
    }
    
    public convenience init(animation: Animatable, count: Int) {
        self.init(animation: animation, type: .Finite, count: count)
    }
    
    public convenience init(animation: Animatable) {
        self.init(animation: animation, type: .Infinite, count: 0)
    }
    
    public func animate(progress: Double) {
        let progressInterval = 1.0 / Double(loopsCount)
        let relativeProgress = (progress % progressInterval) * Double(loopsCount)
        
        loopAnimation.animate(relativeProgress)
    }
    
    public func getDuration() -> Double {
        return Double(loopsCount) * loopAnimation.getDuration()
    }
}
