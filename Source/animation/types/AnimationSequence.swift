import Foundation

public class AnimationSequence: CommonAnimation {
    
    var sequence: [CommonAnimation] = []
    
    
    public required init(animations: [CommonAnimation]) {
        sequence.appendContentsOf(animations)
    }
    
    public convenience init(animation: CommonAnimation) {
        self.init(animations: [animation])
    }
    
    public func addAnimation(animation: CommonAnimation) {
        sequence.append(animation)
    }
    
    public func animate(progress: Double) {
        var progressOffset = 0.0
        let totalDuration = getDuration()
        for animation in sequence {
            
            let prevOffset = progressOffset
            let interval = animation.getDuration() / totalDuration
            progressOffset = progressOffset + interval
            
            if progress < prevOffset {
                continue
            }
            
            if progress > progressOffset {
                continue
            }
            
            let relativeProgress = (progress - prevOffset) / interval
            animation.animate(relativeProgress)
            break
        }
    }
    
    public func getDuration() -> Double {
        return sequence.map { $0.getDuration() }.reduce(0, combine: +)
    }
}
