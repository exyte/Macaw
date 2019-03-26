import Foundation

internal class CombineAnimation: BasicAnimation {

    let animations: [BasicAnimation]
    let toNodes: [Node]
    let duration: Double

    required init(animations: [BasicAnimation], during: Double = 1.0, delay: Double = 0.0, node: Node? = .none, toNodes: [Node] = []) {
        self.animations = animations
        self.duration = during
        self.toNodes = toNodes

        super.init()

        self.type = .combine
        self.node = node ?? animations.first?.node
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
    func combine(delay: Double = 0.0, node: Node? = .none, toNodes: [Node] = []) -> Animation {

        var toCombine = [BasicAnimation]()
        self.forEach { animation in
            toCombine.append(animation as! BasicAnimation)
        }
        return CombineAnimation(animations: toCombine, delay: delay, node: node ?? toCombine.first?.node, toNodes: toNodes)
    }
}
