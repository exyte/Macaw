import Foundation

public class LoopedAnimation: CommonAnimation {
    var loopedlAnimation: CommonAnimation?
    
    public required init(animation: CommonAnimation) {
        loopedlAnimation = AnimationSequence(animations: [animation, RevertedAnimation(animation: animation)])
    }
    
    public func animate(progress: Double) {
        loopedlAnimation?.animate(progress)
    }
    
    public func getDuration() -> Double {
        guard let duration = loopedlAnimation?.getDuration() else {
            return 0.0
        }
        
        return duration
    }
}
