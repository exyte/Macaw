import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

let animationProducer = AnimationProducer()

class AnimationProducer {

    var storedAnimations = [Node: BasicAnimation]()
    var delayedAnimations = [BasicAnimation: Timer]()
    var displayLink: MDisplayLinkProtocol?

    struct ContentAnimationDesc {
        let animation: ContentsAnimation
        let layer: CALayer
        weak var cache: AnimationCache?
        let startDate: Date
        let finishDate: Date
        let completion: (() -> Void)?
    }

    var contentsAnimations = [ContentAnimationDesc]()

    func addAnimation(_ animation: BasicAnimation, withoutDelay: Bool = false) {

        // Delay - launching timer
        if animation.delay > 0.0 && !withoutDelay {

            let timer = Timer.schedule(delay: animation.delay) { [weak self] _ in
                self?.addAnimation(animation, withoutDelay: true)
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
                self.addAnimation(animation)
            }

            if let nextAnimation = animation.next {
                nextAnimation.next = reAdd
            } else {
                animation.next = reAdd
            }
        }

        // General case
        guard let nodeId = animation.nodeId, let node = Node.nodeBy(id: nodeId) else {
            return
        }

        guard let macawView = nodesMap.getView(node) else {
            storedAnimations[node] = animation
            return
        }

        guard let layer = macawView.mLayer else {
            return
        }

        guard let cache = macawView.animationCache else {
            return
        }

        // swiftlint:disable superfluous_disable_command switch_case_alignment
        switch animation.type {
        case .unknown:
            return
        case .affineTransformation:
            addTransformAnimation(animation, sceneLayer: layer, animationCache: cache, completion: {
                if let next = animation.next {
                    self.addAnimation(next)
                }
            })

        case .opacity:
            addOpacityAnimation(animation, sceneLayer: layer, animationCache: cache, completion: {
                if let next = animation.next {
                    self.addAnimation(next)
                }
            })
        case .sequence:
            addAnimationSequence(animation)
        case .combine:
            addCombineAnimation(animation)
        case .contents:
            addContentsAnimation(animation, cache: cache) {
                if let next = animation.next {
                    self.addAnimation(next)
                }
            }
        case .morphing:
            addMorphingAnimation(animation, sceneLayer: layer, animationCache: cache) {
                if let next = animation.next {
                    self.addAnimation(next)
                }
            }
        case .shape:
            addShapeAnimation(animation, sceneLayer: layer, animationCache: cache) {
                if let next = animation.next {
                    self.addAnimation(next)
                }
            }
        case .empty:
            executeCompletion(animation)
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
    fileprivate func addAnimationSequence(_ animationSequnce: Animation) {
        guard let sequence = animationSequnce as? AnimationSequence else {
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
            self.addAnimation(firstAnimation)
        }
    }

    // MARK: - Combine animation
    fileprivate func addCombineAnimation(_ combineAnimation: Animation) {
        guard let combine = combineAnimation as? CombineAnimation else {
            return
        }

        // Reversing
        if combine.autoreverses {
            combine.animations.forEach { animation in
                animation.autoreverses = true
            }
        }

        // repeat count
        if combine.repeatCount > 0.00001 {
            var sequence = [Animation]()

            for _ in 0..<Int(combine.repeatCount) {
                sequence.append(combine)
            }

            combine.repeatCount = 0.0
            addAnimationSequence(sequence.sequence())
            return
        }

        // Looking for longest animation
        var longestAnimation: BasicAnimation?
        combine.animations.forEach { animation in
            guard let longest = longestAnimation else {
                longestAnimation = animation
                return
            }

            if longest.getDuration() < animation.getDuration() {
                longestAnimation = animation
            }
        }

        // Attaching completion empty animation and potential next animation
        if let completion = combine.completion {
            let completionAnimation = EmptyAnimation(completion: completion)
            if let next = combine.next {
                completionAnimation.next = next
            }

            longestAnimation?.next = completionAnimation

        } else {
            if let next = combine.next {
                longestAnimation?.next = next
            }

        }

        combine.removeFunc = { [weak combine] in
            combine?.animations.forEach { animation in
                animation.removeFunc?()
            }
        }

        // Launching
        combine.animations.forEach { animation in
            self.addAnimation(animation)
        }
    }

    // MARK: - Empty Animation
    fileprivate func executeCompletion(_ emptyAnimation: BasicAnimation) {
        emptyAnimation.completion?()
    }

    // MARK: - Stored animation
    func addStoredAnimations(_ node: Node) {
        if let animation = storedAnimations[node] {
            addAnimation(animation)
            storedAnimations.removeValue(forKey: node)
        }

        guard let group = node as? Group else {
            return
        }

        group.contents.forEach { child in
            addStoredAnimations(child)
        }
    }

    // MARK: - Contents animation

    func addContentsAnimation(_ animation: BasicAnimation, cache: AnimationCache?, completion: @escaping (() -> Void)) {
        guard let contentsAnimation = animation as? ContentsAnimation else {
            return
        }

        guard let nodeId = animation.nodeId, let node = Node.nodeBy(id: nodeId) else {
            return
        }

        if animation.autoreverses {
            animation.autoreverses = false
            addAnimation([animation, animation.reverse()].sequence() as! BasicAnimation)
            return
        }

        if animation.repeatCount > 0.0001 {
            animation.repeatCount = 0.0
            var animSequence = [Animation]()
            for _ in 0...Int(animation.repeatCount) {
                animSequence.append(animation)
            }

            addAnimation(animSequence.sequence() as! BasicAnimation)
            return
        }

        let startDate = Date(timeInterval: contentsAnimation.delay, since: Date())

        var unionBounds: Rect? = .none
        if let startBounds = contentsAnimation.getVFunc()(0.0).group().bounds(),
            let endBounds = contentsAnimation.getVFunc()(1.0).group().bounds() {
            unionBounds = startBounds.union(rect: endBounds)
        }

        guard let layer = cache?.layerForNode(node, animation: contentsAnimation, customBounds: unionBounds) else {
            return
        }

        let animationDesc = ContentAnimationDesc(
            animation: contentsAnimation,
            layer: layer,
            cache: cache,
            startDate: Date(),
            finishDate: Date(timeInterval: contentsAnimation.duration, since: startDate),
            completion: completion
        )

        contentsAnimations.append(animationDesc)

        if displayLink == nil {
            displayLink = MDisplayLink()
            displayLink?.startUpdates { [weak self] in
                DispatchQueue.main.async {
                    self?.updateContentAnimations()
                }
            }
        }
    }

    @objc func updateContentAnimations() {
        if contentsAnimations.isEmpty {
            displayLink?.invalidate()
            displayLink = .none
        }

        let currentDate = Date()
        var animationsToRemove = [Animation]()
        let count = contentsAnimations.count
        for (index, animationDesc) in contentsAnimations.reversed().enumerated() {

            let animation = animationDesc.animation
            guard let nodeId = animation.nodeId, let group = Node.nodeBy(id: nodeId) as? Group else {
                continue
            }

            defer {
                animationDesc.layer.setNeedsDisplay()
                animationDesc.layer.displayIfNeeded()
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
                animationDesc.cache?.freeLayer(group)
                animationDesc.completion?()
                continue
            }

            let t = progressForTimingFunction(animation.easing, progress: progress)
            group.contents = animation.getVFunc()(t)
            animation.onProgressUpdate?(progress)

            // Manual stop
            if animation.manualStop || animation.paused {
                defer {
                    contentsAnimations.remove(at: count - 1 - index)
                    animationDesc.cache?.freeLayer(group)
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
