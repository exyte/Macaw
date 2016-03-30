import Foundation

class AnimationSubscription {
    
    var anim: Animation?
    
    var startTime: CFTimeInterval?
    
    init( animation: Animation ) {
        anim = animation
    }
    
    func moveToTimeFrame(position: Double, advance: Double) {
        anim?.animate(position)
    }
}
