import Foundation

internal class AnimationSequence: BasicAnimation {

    let animations: [BasicAnimation]

    required init(animations: [BasicAnimation], delay: Double = 0.0) {
        self.animations = animations

        super.init()

        self.type = .sequence
        self.node = animations.first?.node
        self.delay = delay
    }

    override func getDuration() -> Double {
        let originalDuration = animations.map { $0.getDuration() } .reduce(0) { $0 + $1 }

        if autoreverses {
            return originalDuration * 2.0
        }

        return originalDuration
    }

    open override func stop() {
        super.stop()

        guard let active = animations.first(where: { $0.isActive() }) else {
            return
        }

        active.stop()
    }

    open override func pause() {
        super.pause()

        guard let active = animations.first(where: { $0.isActive() }) else {
            return
        }

        active.pause()
    }

    open override func play() {
        guard let active = animations.first(where: { $0.isActive() }) else {
            super.play()
            return
        }

        manualStop = false
        paused = false

        active.play()
    }

    open override func state() -> AnimationState {
        for animation in animations {
            let state = animation.state()
            if  state != .initial {
                return state
            }
        }

        return .initial
    }

    open override func reverse() -> Animation {
        var reversedAnimations = [BasicAnimation]()
        animations.forEach { animation in
            reversedAnimations.append(animation.reverse() as! BasicAnimation)
        }

        let reversedSequence = reversedAnimations.reversed().sequence(delay: self.delay) as! BasicAnimation
        reversedSequence.completion = completion
        reversedSequence.progress = progress

        return reversedSequence
    }
}

public extension Sequence where Iterator.Element: Animation {
    func sequence(delay: Double = 0.0) -> Animation {

        var sequence = [BasicAnimation]()
        self.forEach { animation in
            sequence.append(animation as! BasicAnimation)
        }
        return AnimationSequence(animations: sequence, delay: delay)
    }
}
