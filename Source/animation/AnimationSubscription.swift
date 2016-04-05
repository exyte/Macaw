import Foundation

class AnimationSubscription {
    
    let anim: Animatable
    
    var startTime: CFTimeInterval?
    
    init( animation: Animatable ) {
        anim = animation
    }
    
    func moveToTimeFrame(position: Double, advance: Double) {
        anim.animate(position)
    }
}
