import Foundation

class AnimationSubscription {
    
    var anim: CommonAnimation?
    
    var startTime: CFTimeInterval?
    
    init( animation: CommonAnimation ) {
        anim = animation
    }
    
    func moveToTimeFrame(position: Double, advance: Double) {
        anim?.animate(position)
    }
}
