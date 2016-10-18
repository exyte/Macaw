import RxSwift

internal class ContentsAnimation: AnimationImpl<[Node]> {
    
    init(animatedGroup: Group, valueFunc: @escaping (Double, [Node]) -> Void, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        
        let nativeValueFunc = { (t: Double) -> [Node] in
            valueFunc(t, animatedGroup.contents)
            return animatedGroup.contents
        }
        
        super.init(observableValue: animatedGroup.contentsVar, valueFunc: nativeValueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .contents
        node = animatedGroup
        
        if autostart {
            self.play()
        }
    }
}
