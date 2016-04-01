import Foundation


public extension CommonAnimation {
    public func revert() -> CommonAnimation {
        return RevertedAnimation(animation: self)
    }
}

public class RevertedAnimation: CommonAnimation {
    var originalAnimation: CommonAnimation?
    
    public required init(animation: CommonAnimation) {
        originalAnimation = animation
    }
    
    public func animate(progress: Double) {
        originalAnimation?.animate(1.0 - progress)
    }
    
    public func getDuration() -> Double {
        guard let duration = originalAnimation?.getDuration() else {
            return 0.0
        }
        
        return duration
    }
}
