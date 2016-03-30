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
        animationSubscriptions.forEach { subscription in
            
            guard let animation = subscription.anim else {
                return
            }
            
            if subscription.startTime == .None {
                subscription.startTime = displayLink.timestamp
            }
            
            guard let startTime = subscription.startTime else {
                return
            }
            
            let timePosition = displayLink.timestamp - startTime
            let position = timePosition - animation.getDuration()
            subscription.moveToTimeFrame(position, advance: 0)
            rendererCall?()
        }
    }
}
