import Foundation

public enum RepetitiveAnimationType {
    case Finite
    case Infinite
}

public class RepetitiveAnimation: CommonAnimation {
    
    var loopAnimation: CommonAnimation?
    var loopsCount = 0
    
    public required init(animation: CommonAnimation, type: RepetitiveAnimationType, count: Int) {
        loopAnimation = animation
        loopsCount    = count
        
        if type == .Infinite {
            loopsCount = Int.max
        }
    }
    
    public convenience init(animation: CommonAnimation, count: Int) {
        self.init(animation: animation, type: .Finite, count: count)
    }
    
    public convenience init(animation: CommonAnimation) {
        self.init(animation: animation, type: .Infinite, count: 0)
    }
    
    public func animate(progress: Double) {
        let progressInterval = 1.0 / Double(loopsCount)
        let relativeProgress = (progress % progressInterval) * Double(loopsCount)
        
        loopAnimation?.animate(relativeProgress)
    }
    
    public func getDuration() -> Double {
        guard let duration = loopAnimation?.getDuration() else {
            return 0
        }
    
        return Double(loopsCount) * duration
    }
}
