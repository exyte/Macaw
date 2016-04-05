import Foundation
import QuartzCore

class AnimationLoop {
    
    var displayLink: CADisplayLink?
    
    var animationSubscriptions: [AnimationSubscription] = []
    var rendererCall: (()->())?
    
    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(onFrameUpdate(_:)))
        displayLink?.paused = false
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    dynamic private func onFrameUpdate(displayLink: CADisplayLink) {
        
        var toRemove = [AnimationSubscription]()
        
        animationSubscriptions.forEach { subscription in
            
            if subscription.startTime == .None {
                subscription.startTime = displayLink.timestamp
            }
            
            guard let startTime = subscription.startTime else {
                return
            }
            
            let timePosition = displayLink.timestamp - startTime
            let position = timePosition / subscription.anim.getDuration()
            
            if position > 1.0 {
                toRemove.append(subscription)
            }
            
            subscription.moveToTimeFrame(position, advance: 0)
        }
        
        rendererCall?()
        
        // Removing
        toRemove.forEach { subsription in
            if let index = animationSubscriptions.indexOf ({ $0 === subsription }) {
                animationSubscriptions.removeAtIndex(index)
            }
        }
    }
}
