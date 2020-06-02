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

func addPathAnimation(_ animation: BasicAnimation, _ context: AnimationContext, sceneLayer: CALayer, completion: @escaping (() -> Void)) {

    guard let shape = animation.node as? Shape, let renderer = animation.nodeRenderer else {
        return
    }

    let duration = animation.autoreverses ? animation.getDuration() / 2.0 : animation.getDuration()

    let layer = AnimationUtils.layerForNodeRenderer(renderer, animation: animation, shouldRenderContent: false)

    // Creating proper animation
    let generatedAnim = generatePathAnimation(from: 0.0, to: 1.0, duration: duration)

    generatedAnim.repeatCount = Float(animation.repeatCount)
    generatedAnim.timingFunction = caTimingFunction(animation.easing)
    generatedAnim.autoreverses = animation.autoreverses

    generatedAnim.progress = { progress in
        let t = Double(progress)

        animation.progress = t
        animation.onProgressUpdate?(t)
    }

    generatedAnim.completion = { finished in

        animation.progress = animation.manualStop ? 0.0 : 1.0

        renderer.freeLayer()

        if !animation.cycled && !animation.manualStop {
            animation.completion?()
        }

        completion()
    }

    //layer.path = RenderUtils.toCGPath(shape.form).copy(using: &layer.transform)
    layer.path = shape.form.toCGPath()
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
