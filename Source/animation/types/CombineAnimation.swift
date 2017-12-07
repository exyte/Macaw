import Foundation

internal class CombineAnimation: BasicAnimation {

    let animations: [BasicAnimation]

    required init(animations: [BasicAnimation], delay: Double = 0.0, node: Node? = .none) {
        self.animations = animations

        super.init()

        self.type = .combine
        self.nodeId = nodeId ?? animations.first?.nodeId
        self.delay = delay
    }

    override func getDuration() -> Double {
        if let maxElement = animations.map({ $0.getDuration() }).max() {
            return maxElement
        }

        return 0.0
    }

    open override func reverse() -> Animation {
        var reversedAnimations = [BasicAnimation]()
        animations.forEach { animation in
            reversedAnimations.append(animation.reverse() as! BasicAnimation)
        }

        let combineReversed = reversedAnimations.combine(delay: self.delay) as! BasicAnimation
        combineReversed.completion = completion
        combineReversed.progress = progress

        return combineReversed
    }

    open override func play() {
        animations.forEach { animation in
            animation.paused = false
            animation.manualStop = false
        }

        super.play()
    }

    open override func stop() {
        super.stop()

        animations.forEach { animation in
            animation.stop()
        }
    }

    open override func pause() {
        super.pause()

        animations.forEach { animation in
            animation.pause()
        }
    }

    open override func state() -> AnimationState {
        var result = AnimationState.initial
        for animation in animations {
            let state = animation.state()
            if state == .running {
                return .running
            }

            if state != .initial {
                result = state
            }
        }

        return result
    }
}

public extension Sequence where Iterator.Element: Animation {
    public func combine(delay: Double = 0.0, node: Node? = .none) -> Animation {

        var toCombine = [BasicAnimation]()
        self.forEach { animation in
            toCombine.append(animation as! BasicAnimation)
        }
        return CombineAnimation(animations: toCombine, delay: delay, node: node)
    }
}
