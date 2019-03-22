//
//  PathAnimationGenerator.swift
//  Macaw
//
//  Created by Victor Sukochev on 01/01/2018.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

func addPathAnimation(_ animation: BasicAnimation, _ context: AnimationContext, sceneLayer: CALayer, animationCache: AnimationCache?, completion: @escaping (() -> Void)) {

    guard let shape = animation.node as? Shape, let renderer = animation.nodeRenderer else {
        return
    }

    let duration = animation.autoreverses ? animation.getDuration() / 2.0 : animation.getDuration()

    guard let layer = animationCache?.layerForNodeRenderer(renderer, context, animation: animation, shouldRenderContent: false) else {
        return
    }

    // Creating proper animation
    let generatedAnim = generatePathAnimation(from: 0.0, to: 1.0, duration: duration)

    generatedAnim.repeatCount = Float(animation.repeatCount)
    generatedAnim.timingFunction = caTimingFunction(animation.easing)
    generatedAnim.autoreverses = animation.autoreverses

    generatedAnim.completion = { finished in

        animationCache?.freeLayer(renderer)

        if !animation.cycled && !animation.manualStop {
            animation.completion?()
        }

        completion()
    }

    generatedAnim.progress = { progress in
        let t = Double(progress)

        animation.progress = t
        animation.onProgressUpdate?(t)
    }

    layer.path = RenderUtils.toCGPath(shape.form).copy(using: &layer.renderTransform!)
    layer.setupStrokeAndFill(shape)

    layer.add(generatedAnim, forKey: animation.ID)
    animation.removeFunc = { [weak layer] in
        layer?.removeAnimation(forKey: animation.ID)
    }
}

fileprivate func generatePathAnimation(from: Double, to: Double, duration: Double) -> CAAnimation {

    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.fromValue = from
    animation.toValue = to
    animation.duration = duration
    animation.fillMode = CAMediaTimingFillMode.forwards
    animation.isRemovedOnCompletion = false

    return animation
}
