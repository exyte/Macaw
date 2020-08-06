//
//  MorphingGenerator.swift
//  Pods
//
//  Created by Victor Sukochev on 24/01/2017.
//
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

func addMorphingAnimation(_ animation: BasicAnimation, _ context: AnimationContext, sceneLayer: CALayer?, completion: @escaping (() -> Void)) {
    guard let morphingAnimation = animation as? MorphingAnimation else {
        return
    }

    guard let shape = animation.node as? Shape, let renderer = animation.nodeRenderer else {
        return
    }

    let transactionsDisabled = CATransaction.disableActions()
    CATransaction.setDisableActions(true)

    let fromLocus = morphingAnimation.getVFunc()(0.0)
    let toLocus = morphingAnimation.getVFunc()(animation.autoreverses ? 0.5 : 1.0)
    let duration = animation.autoreverses ? animation.getDuration() / 2.0 : animation.getDuration()

    let layer = AnimationUtils.layerForNodeRenderer(renderer, animation: animation, shouldRenderContent: false)

    // Creating proper animation
    let generatedAnimation = pathAnimation(
        from: fromLocus,
        to: toLocus,
        duration: duration)

    generatedAnimation.repeatCount = Float(animation.repeatCount)
    generatedAnimation.timingFunction = caTimingFunction(animation.easing)
    generatedAnimation.autoreverses = animation.autoreverses

    generatedAnimation.progress = { progress in
        let t = Double(progress)
        animation.progress = t
        animation.onProgressUpdate?(t)
    }

    generatedAnimation.completion = { finished in

        if animation.manualStop {
            animation.progress = 0.0
            shape.form = morphingAnimation.getVFunc()(0.0)
        } else if finished {
            animation.progress = 1.0
            shape.form = morphingAnimation.getVFunc()(1.0)
        }

        renderer.freeLayer()

        if  !animation.cycled &&
                !animation.manualStop {
            animation.completion?()
        }

        completion()
    }

    layer.path = fromLocus.toCGPath()
    layer.setupStrokeAndFill(shape)

    let animationId = animation.ID
    layer.add(generatedAnimation, forKey: animationId)
    animation.removeFunc = { [weak layer] in
        shape.animations.removeAll { $0 === animation }
        layer?.removeAnimation(forKey: animationId)
    }

    if !transactionsDisabled {
        CATransaction.commit()
    }
}

fileprivate func pathAnimation(from: Locus, to: Locus, duration: Double) -> CAAnimation {

    let fromPath = from.toCGPath()
    let toPath = to.toCGPath()

    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = fromPath
    animation.toValue = toPath
    animation.duration = duration
    animation.fillMode = MCAMediaTimingFillMode.forwards
    animation.isRemovedOnCompletion = false

    return animation
}
