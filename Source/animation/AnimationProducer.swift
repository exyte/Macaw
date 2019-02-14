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
        let layer: CALayer
        weak var cache: AnimationCache?
        let topRenderers: [NodeRenderer]
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

        guard let cache = macawView.animationCache else {
            return
        }

        // swiftlint:disable superfluous_disable_command switch_case_alignment
        switch animation.type {
        case .affineTransformation:
            addTransformAnimation(animation, context, sceneLayer: layer, animationCache: cache, completion: {
                if let next = animation.next {
                    self.play(next, context)
                }
            })
        case .opacity:
            addOpacityAnimation(animation, context, sceneLayer: layer, animationCache: cache, completion: {
                if let next = animation.next {
                    self.play(next, context)
                }
            })
        case .contents:
            addContentsAnimation(animation, context, cache: cache) {
                if let next = animation.next {
                    self.play(next, context)
                }
            }
        case .morphing:
            addMorphingAnimation(animation, context, sceneLayer: layer, animationCache: cache) {
                if let next = animation.next {
                    self.play(next, context)
                }
            }
        case .shape:
            addShapeAnimation(animation, context, sceneLayer: layer, animationCache: cache) {
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
    func addAnimationSequence(_ animationSequnce: Animation,
                              _ context: AnimationContext) {
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
            self.play(firstAnimation, context)
        }
    }

    // MARK: - Empty Animation
    fileprivate func executeCompletion(_ emptyAnimation: BasicAnimation) {
        emptyAnimation.completion?()
    }

    // MARK: - Stored animation
    func addStoredAnimations(_ node: Node, _ view: MacawView) {
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

    func addContentsAnimation(_ animation: BasicAnimation, _ context: AnimationContext, cache: AnimationCache?, completion: @escaping (() -> Void)) {
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

        var unionBounds = contentsAnimation.getVFunc()(0.0).group().bounds
        stride(from: 0.0, to: 1.0, by: 0.02).forEach { progress in
            let t = animation.easing.progressFor(time: progress)
            unionBounds = unionBounds?.union(rect: contentsAnimation.getVFunc()(t).group().bounds!)
        }

        guard let renderer = animation.nodeRenderer, let layer = cache?.layerForNodeRenderer(renderer, context, animation: contentsAnimation, customBounds: unionBounds) else {
            return
        }

        var rootRenderer: NodeRenderer? = renderer
        while rootRenderer?.parentRenderer != nil {
            rootRenderer = rootRenderer?.parentRenderer
        }
        let allRenderers = rootRenderer?.getAllChildrenRecursive()

        var animationRenderers = [NodeRenderer]()
        if let groupRenderer = renderer as? GroupRenderer {
            animationRenderers.append(contentsOf: groupRenderer.renderers)
        }
        let bottomRenderer = animationRenderers.min { $0.zPosition < $1.zPosition }

        var topRenderers = [NodeRenderer]()
        if let bottomRenderer = bottomRenderer, let allRenderers = allRenderers {
            for renderer in allRenderers where !(renderer is GroupRenderer) && renderer.zPosition > bottomRenderer.zPosition {
                topRenderers.append(renderer)
            }
        }

        let animationDesc = ContentAnimationDesc(
            animation: contentsAnimation,
            layer: layer,
            cache: cache,
            topRenderers: topRenderers,
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
        var animationsToRemove = [Animation]()
        let count = contentsAnimations.count
        for (index, animationDesc) in contentsAnimations.reversed().enumerated() {

            let animation = animationDesc.animation
            guard let group = animation.node as? Group, let renderer = animation.nodeRenderer else {
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
                animationDesc.cache?.freeLayer(renderer)
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
                    animationDesc.cache?.freeLayer(renderer)
                }

                if animation.manualStop {
                    animation.pausedProgress = 0.0
                    group.contents = animation.getVFunc()(0)
                } else if animation.paused {
                    animation.pausedProgress = progress
                }
            }

            for renderer in animationDesc.topRenderers {
                let layer = animationDesc.cache?.layerForNodeRenderer(renderer, context, animation: animationDesc.animation)
                layer?.setNeedsDisplay()
                layer?.displayIfNeeded()
            }
        }
    }
}

class AnimationContext {

    var rootTransform: Transform?

    func getLayoutTransform(_ renderer: NodeRenderer?) -> Transform {
        if rootTransform == nil {
            if let view = renderer?.view, let node = view.renderer?.node() {
                rootTransform = LayoutHelper.calcTransform(node, view.contentLayout, view.bounds.size.toMacaw())
            }
        }
        return rootTransform ?? Transform.identity
    }

}
