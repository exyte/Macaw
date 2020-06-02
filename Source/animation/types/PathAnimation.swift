//
//  PathAnimation.swift
//  Macaw
//
//  Created by Victor Sukochev on 01/01/2018.
//

import Foundation

class PathAnimation: AnimationImpl<Locus> {
    convenience init(animatedNode: Shape, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {

        let interpolationFunc = { (t: Double) -> Locus in
            return animatedNode.form
        }

        self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, delay: delay, autostart: autostart, fps: fps)
    }

    init(animatedNode: Shape, valueFunc: @escaping (Double) -> Locus, animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.formVar, valueFunc: valueFunc, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .path
        node = animatedNode

        if autostart {
            self.play()
        }
    }

    init(animatedNode: Shape, factory: @escaping (() -> ((Double) -> Locus)), animationDuration: Double, delay: Double = 0.0, autostart: Bool = false, fps: UInt = 30) {
        super.init(observableValue: animatedNode.formVar, factory: factory, animationDuration: animationDuration, delay: delay, fps: fps)
        type = .path
        node = animatedNode

        if autostart {
            self.play()
        }
    }

    // Pause state not available for discreet animation
    override public func pause() {
        stop()
    }
}

public typealias PathAnimationDescription = AnimationDescription<Locus>

public extension AnimatableVariable where T: LocusInterpolation {
    func appearanceAnimation(during: Double = 1.0, delay: Double = 0.0) -> Animation {
        return PathAnimation(animatedNode: node as! Shape, animationDuration: during, delay: delay, autostart: false)
    }
}

// MARK: - Group

public extension AnimatableVariable where T: ContentsInterpolation {
    func appearanceAnimation(during: Double = 1.0, delay: Double = 0.0) -> Animation {
        let group = node as! Group
        let shapes = group.contents.compactMap { $0 as? Shape }
        var animations = shapes.map { $0.formVar.appearanceAnimation(during: during, delay: delay) }

        let groups = group.contents.compactMap { $0 as? Group }
        let groupAnimations = groups.map({ $0.contentsVar.appearanceAnimation(during: during, delay: delay) })

        animations.append(contentsOf: groupAnimations)

        return animations.combine(node: node)
    }
}
