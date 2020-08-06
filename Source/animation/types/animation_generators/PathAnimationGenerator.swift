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

    guard let pathAnimation = animation as? PathAnimation, let shape = animation.node as? Shape, let renderer = animation.nodeRenderer else {
        return
    }

    let layer = AnimationUtils.layerForNodeRenderer(renderer, animation: animation, shouldRenderContent: false)

    // Creating proper animation
    let generatedAnim = generatePathAnimation(
        pathAnimation.getVFunc(),
        duration: animation.getDuration(),
        offset: animation.pausedProgress,
        fps: pathAnimation.logicalFps)

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

fileprivate func generatePathAnimation(_ valueFunc: (Double) -> Double, duration: Double, offset: Double, fps: UInt) -> CAAnimation {

    var strokeEndValues = [Double]()
    var timeValues = [Double]()

    let step = 1.0 / (duration * Double(fps))

    var dt = 0.0
    var tValue = Array(stride(from: 0.0, to: 1.0, by: step))
    tValue.append(1.0)
    for t in tValue {

        dt = t
        if 1.0 - dt < step {
            dt = 1.0
        }

        let value = valueFunc(offset + dt)
        strokeEndValues.append(value)
        timeValues.append(dt)
    }

    let animation = CAKeyframeAnimation(keyPath: "strokeEnd")
    animation.fillMode = MCAMediaTimingFillMode.forwards
    animation.isRemovedOnCompletion = false

    animation.duration = duration
    animation.values = strokeEndValues
    animation.keyTimes = timeValues as [NSNumber]?

    return animation
}
