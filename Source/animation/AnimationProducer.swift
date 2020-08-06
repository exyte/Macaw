import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

let animationProducer = AnimationProducer()

class AnimationProducer {

    var storedAnimations = [Node: BasicAnimation]() // is used to make sure node is in view hierarchy before actually creating the animation
    var delayedAnimations = [BasicAnimation: Timer]()
    var displayLink: MDisplayLinkProtocol?

    struct ContentAnimationDesc {
        let animation: ContentsAnimation
        let startDate: Date
        let finishDate: Date
        let completion: (() -> Void)?
    }

    var contentsAnimations = [ContentAnimationDesc]()

    func play(_ animation: BasicAnimation, _ context: AnimationContext, withoutDelay: Bool = false) {

        // Delay - launching timer
        if animation.delay > 0.0 && !withoutDelay {

            let timer = Timer.schedule(delay: animation.delay) { [weak self] _ in
                self?.play(animation, context, withoutDelay: true)
                _ = self?.delayedAnimations.removeValue(forKey: animation)
                animation.delayed = false
            }

            animation.delayed = true
            delayedAnimations[animation] = timer

            return
        }

        // Empty - executing completion
        if animation.type == .empty {
            executeCompletion(animation)
            return
        }

        // Cycle - attaching "re-add animation" logic
        if animation.cycled {
            if animation.manualStop {
                return
            }

            let reAdd = EmptyAnimation {
                self.play(animation, context)
            }

            if let nextAnimation = animation.next {
                nextAnimation.next = reAdd
            } else {
                animation.next = reAdd
            }
        }

        // General case
        guard let node = animation.node else {
            return
        }
        for observer in node.animationObservers {
            observer.processAnimation(animation)
        }

        switch animation.type {
        case .unknown:
            return
        case .empty:
            executeCompletion(animation)
        case .sequence:
            addAnimationSequence(animation, context)
        case .combine:
            addCombineAnimation(animation, context)
        default:
            break
        }

        guard let macawView = animation.nodeRenderer?.view else {
            storedAnimations[node] = animation
            return
        }

        guard let layer = macawView.mLayer else {
            return
        }

        // swiftlint:disable superfluous_disable_command switch_case_alignment
        switch animation.type {
        case .affineTransformation:
            addTransformAnimation(animation, context, sceneLayer: layer, completion: {
                if let next = animation.next {
                    self.play(next, context)
                }
            })
        case .opacity:
            addOpacityAnimation(animation, context, sceneLayer: layer, completion: {
                if let next = animation.next {
                    self.play(next, context)
                }
            })
        case .contents:
            addContentsAnimation(animation, context) {
                if let next = animation.next {
                    self.play(next, context)
                }
            }
        case .morphing:
            addMorphingAnimation(animation, context, sceneLayer: layer) {
                if let next = animation.next {
                    self.play(next, context)
                }
            }
        case .shape:
            addShapeAnimation(animation, context, sceneLayer: layer) {
                if let next = animation.next {
                    self.play(next, context)
                }
            }
        case .path:
            addPathAnimation(animation, context, sceneLayer: layer) {
                if let next = animation.next {
                    self.play(next, context)
                }
            }
        default:
            break
        }
        // swiftlint:enable superfluous_disable_command switch_case_alignment
    }

    func removeDelayed(animation: BasicAnimation) {
        guard let timer = delayedAnimations[animation] else {
            return
        }

        timer.invalidate()

        animation.delayed = false
        delayedAnimations.removeValue(forKey: animation)
    }

    // MARK: - Sequence animation
    func addAnimationSequence(_ animationSequence: Animation,
                              _ context: AnimationContext) {
        guard let sequence = animationSequence as? AnimationSequence else {
            return
        }

        // Generating sequence
        var sequenceAnimations = [BasicAnimation]()
        var cycleAnimations = sequence.animations

        if sequence.autoreverses {
            cycleAnimations.append(contentsOf: sequence.animations.reversed())
        }

        if sequence.repeatCount > 0.0001 {
            for _ in 0..<Int(sequence.repeatCount) {
                sequenceAnimations.append(contentsOf: cycleAnimations)
            }
        } else {
            sequenceAnimations.append(contentsOf: cycleAnimations)
        }

        // Connecting animations
        for i in 0..<(sequenceAnimations.count - 1) {
            let animation = sequenceAnimations[i]
            animation.next = sequenceAnimations[i + 1]
        }

        // Completion
        if let completion = sequence.completion {
            let completionAnimation = EmptyAnimation(completion: completion)

            if let next = sequence.next {
                completionAnimation.next = next
            }

            sequenceAnimations.last?.next = completionAnimation
        } else {
            if let next = sequence.next {
                sequenceAnimations.last?.next = next
            }
        }

        // Launching
        if let firstAnimation = sequence.animations.first {
            self.play(firstAnimation, context)
        }
    }

    // MARK: - Empty Animation
    fileprivate func executeCompletion(_ emptyAnimation: BasicAnimation) {
        emptyAnimation.completion?()
    }

    // MARK: - Stored animation
    func addStoredAnimations(_ node: Node, _ view: DrawingView) {
        addStoredAnimations(node, AnimationContext())
    }

    func addStoredAnimations(_ node: Node, _ context: AnimationContext) {
        if let animation = storedAnimations[node] {
            play(animation, context)
            storedAnimations.removeValue(forKey: node)
        }

        guard let group = node as? Group else {
            return
        }

        group.contents.forEach { child in
            addStoredAnimations(child, context)
        }
    }

    // MARK: - Contents animation

    func addContentsAnimation(_ animation: BasicAnimation, _ context: AnimationContext, completion: @escaping (() -> Void)) {
        guard let contentsAnimation = animation as? ContentsAnimation else {
            return
        }

        if animation.autoreverses {
            animation.autoreverses = false
            play([animation, animation.reverse()].sequence() as! BasicAnimation, context)
            return
        }

        if animation.repeatCount > 0.0001 {
            animation.repeatCount = 0.0
            var animSequence = [Animation]()
            for _ in 0...Int(animation.repeatCount) {
                animSequence.append(animation)
            }

            play(animSequence.sequence() as! BasicAnimation, context)
            return
        }

        let startDate = Date(timeInterval: contentsAnimation.delay, since: Date())

        let animationDesc = ContentAnimationDesc(
            animation: contentsAnimation,
            startDate: Date(),
            finishDate: Date(timeInterval: contentsAnimation.duration, since: startDate),
            completion: completion
        )

        contentsAnimations.append(animationDesc)

        if displayLink == nil {
            displayLink = MDisplayLink()
            displayLink?.startUpdates { [weak self] in
                DispatchQueue.main.async {
                    self?.updateContentAnimations(context)
                }
            }
        }
    }

    func updateContentAnimations(_ context: AnimationContext) {
        if contentsAnimations.isEmpty {
            displayLink?.invalidate()
            displayLink = .none
        }

        let currentDate = Date()
        let count = contentsAnimations.count
        for (index, animationDesc) in contentsAnimations.reversed().enumerated() {

            let animation = animationDesc.animation
            guard let group = animation.node as? Group, let renderer = animation.nodeRenderer else {
                continue
            }

            defer {
                renderer.sceneLayer?.setNeedsDisplay()
            }

            let progress = currentDate.timeIntervalSince(animationDesc.startDate) / animation.duration + animation.pausedProgress

            // Completion
            if progress >= 1.0 {

                // Final update
                group.contents = animation.getVFunc()(1.0)
                animation.onProgressUpdate?(1.0)
                animation.pausedProgress = 0.0

                // Finishing animation
                if !animation.cycled {
                    animation.completion?()
                }

                contentsAnimations.remove(at: count - 1 - index)
                renderer.freeLayer()
                animationDesc.completion?()
                continue
            }

            let t = animation.easing.progressFor(time: progress)
            group.contents = animation.getVFunc()(t)
            animation.onProgressUpdate?(progress)

            // Manual stop
            if animation.manualStop || animation.paused {
                defer {
                    contentsAnimations.remove(at: count - 1 - index)
                    renderer.freeLayer()
                }

                if animation.manualStop {
                    animation.pausedProgress = 0.0
                    group.contents = animation.getVFunc()(0)
                } else if animation.paused {
                    animation.pausedProgress = progress
                }
            }
        }
    }
}

class AnimationContext {

    var rootTransform: Transform?

    func getLayoutTransform(_ renderer: NodeRenderer?) -> Transform {
        if rootTransform == nil {
            if let view = renderer?.view {
                rootTransform = view.place
            }
        }
        return rootTransform ?? Transform.identity
    }

}
