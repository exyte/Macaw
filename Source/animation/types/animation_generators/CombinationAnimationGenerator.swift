//
//  CombinationAnimationGenerator.swift
//  Macaw
//
//  Created by Alisa Mylnikova on 17/12/2018.
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

extension AnimationProducer {

    func createChildAnimations(_ combineAnimation: Animation, animations: [Animation] = []) -> [Animation] {
        guard let combine = combineAnimation as? CombineAnimation else {
            return animations
        }

        let during = combine.duration
        let delay = combine.delay
        let fromNode = combine.node as! Group
        let to = combine.toNodes

        let fromContentsCopy = fromNode.contents.compactMap { SceneUtils.copyNode($0) }
        fromNode.contents = fromContentsCopy

        // Shapes on same hierarhy level
        let fromShapes = fromContentsCopy.compactMap { $0 as? Shape }
        let toShapes = to.compactMap { $0 as? Shape }
        let minPathsNumber = min(fromShapes.count, toShapes.count)

        var animations = [Animation]()
        for i in 0..<minPathsNumber {
            let fromShape = fromShapes[i]
            let toShape = toShapes[i]

            let animation = ShapeAnimation(animatedNode: fromShape, finalValue: toShape, animationDuration: during, delay: delay)
            animations.append(animation)
        }

        if fromShapes.count > minPathsNumber {
            for i in minPathsNumber..<fromShapes.count {
                let shapeToHide = fromShapes[i]
                let animation = shapeToHide.opacityVar.animation(to: 0.0, during: during, delay: delay)
                animations.append(animation)
            }
        }

        if toShapes.count > minPathsNumber {
            for i in minPathsNumber..<toShapes.count {
                let shapeToShow = toShapes[i]
                shapeToShow.opacity = 0.0
                fromNode.contents.append(shapeToShow)

                let animation = shapeToShow.opacityVar.animation(to: 1.0, during: during, delay: delay)
                animations.append(animation)
            }
        }

        // Groups on same hierahy level
        let fromGroups = fromNode.contents.compactMap { $0 as? Group }
        let toGroups = to.compactMap { $0 as? Group }
        let minGroupsNumber = min(fromGroups.count, toGroups.count)
        for i in 0..<minGroupsNumber {
            let fromGroup = fromGroups[i]
            let toGroup = toGroups[i]

            let groupAnimation = fromGroup.contentsVar.animation(to: toGroup.contents, during: during, delay: delay)
            let groupAnimations = createChildAnimations(groupAnimation, animations: animations)
            animations.append(contentsOf: groupAnimations)
        }

        for i in minGroupsNumber..<fromGroups.count {
            let groupToHide = fromGroups[i]
            let animation = groupToHide.opacityVar.animation(to: 0.0, during: during, delay: delay)
            animations.append(animation)
        }

        for i in minGroupsNumber..<toGroups.count {
            let groupToShow = toGroups[i]
            groupToShow.opacity = 0.0
            fromNode.contents.append(groupToShow)

            let animation = groupToShow.opacityVar.animation(to: 1.0, during: during, delay: delay)
            animations.append(animation)
        }

        // Rest nodes
        let fromNodes = fromNode.contents.filter {
            !($0 is Group || $0 is Shape)
        }

        let toNodes = to.filter {
            !($0 is Group || $0 is Shape)
        }

        fromNodes.forEach { node in
            let animation = node.opacityVar.animation(to: 0.0, during: during, delay: delay)
            animations.append(animation)
        }

        toNodes.forEach { node in
            node.opacity = 0.0
            fromNode.contents.append(node)

            let animation = node.opacityVar.animation(to: 1.0, during: during, delay: delay)
            animations.append(animation)
        }

        return animations
    }

    // MARK: - Combine animation
    func addCombineAnimation(_ combineAnimation: Animation, _ context: AnimationContext) {
        guard let combine = combineAnimation as? CombineAnimation,
              let _ = combine.nodeRenderer,
              let node = combine.node else {
            return
        }

        var animations = combine.animations
        if let _ = combine.node?.bounds, let _ = combine.toNodes.group().bounds {
            let childAnimations = createChildAnimations(combine) as! [BasicAnimation]
            animations.append(contentsOf: childAnimations)
        }

        // Reversing
        if combine.autoreverses {
            animations.forEach { animation in
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
            addAnimationSequence(sequence.sequence(), context)
            return
        }

        // Looking for longest animation
        var longestAnimation: BasicAnimation?
        animations.forEach { animation in
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

        combine.removeFunc = {
            node.animations.removeAll { $0 === combine }
            animations.forEach { animation in
                animation.removeFunc?()
            }
        }

        CATransaction.setDisableActions(true)
        defer {
            CATransaction.commit()
        }

        // Launching
        animations.forEach { animation in
            self.play(animation, context)
        }
    }

}
