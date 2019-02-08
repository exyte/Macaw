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

func addMorphingAnimation(_ animation: BasicAnimation, _ context: AnimationContext, sceneLayer: CALayer, animationCache: AnimationCache?, completion: @escaping (() -> Void)) {
    guard let morphingAnimation = animation as? MorphingAnimation else {
        return
    }

    guard let shape = animation.node as? Shape, let renderer = animation.nodeRenderer else {
        return
    }

    let mutatingShape = SceneUtils.shapeCopy(from: shape)
    renderer.replaceNode(with: mutatingShape)
    animation.node = mutatingShape

    let fromLocus = morphingAnimation.getVFunc()(0.0)
    let toLocus = morphingAnimation.getVFunc()(animation.autoreverses ? 0.5 : 1.0)
    let duration = animation.autoreverses ? animation.getDuration() / 2.0 : animation.getDuration()

    guard let layer = animationCache?.layerForNodeRenderer(renderer, context, animation: animation, shouldRenderContent: false) else {
        return
    }
    // Creating proper animation
    let generatedAnim = pathAnimation(
        from: fromLocus,
        to: toLocus,
        duration: duration,
        renderTransform: layer.renderTransform!)

    generatedAnim.repeatCount = Float(animation.repeatCount)
    generatedAnim.timingFunction = caTimingFunction(animation.easing)
    generatedAnim.autoreverses = animation.autoreverses

    generatedAnim.completion = { finished in

        if animation.manualStop {
            animation.progress = 0.0
            mutatingShape.form = morphingAnimation.getVFunc()(0.0)
        } else if finished {
            animation.progress = 1.0
            mutatingShape.form = morphingAnimation.getVFunc()(1.0)
        }

        animationCache?.freeLayer(renderer)

        if  !animation.cycled &&
            !animation.manualStop {
            animation.completion?()
        }

        completion()
    }

    generatedAnim.progress = { progress in

        let t = Double(progress)
        mutatingShape.form = morphingAnimation.getVFunc()(t)

        animation.progress = t
        animation.onProgressUpdate?(t)
    }

    layer.path = fromLocus.toCGPath()

    // Stroke
    if let stroke = mutatingShape.stroke {
        if let color = stroke.fill as? Color {
            layer.strokeColor = color.toCG()
        } else {
            layer.strokeColor = MColor.black.cgColor
        }

        layer.lineWidth = CGFloat(stroke.width)
        layer.lineCap = MCAShapeLayerLineCap.mapToGraphics(model: stroke.cap)
        layer.lineJoin = MCAShapeLayerLineJoin.mapToGraphics(model: stroke.join)
        layer.lineDashPattern = stroke.dashes.map { NSNumber(value: $0) }
    }

    // Fill
    if let color = mutatingShape.fill as? Color {
        layer.fillColor = color.toCG()
    } else {
        layer.fillColor = MColor.clear.cgColor
    }

    let animationId = animation.ID
    layer.add(generatedAnim, forKey: animationId)
    animation.removeFunc = { [weak layer] in
        layer?.removeAnimation(forKey: animationId)
    }
}

fileprivate func pathAnimation(from: Locus, to: Locus, duration: Double, renderTransform: CGAffineTransform) -> CAAnimation {

    var transform = renderTransform
    let fromPath = from.toCGPath().copy(using: &transform)
    let toPath = to.toCGPath().copy(using: &transform)

    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = fromPath
    animation.toValue = toPath
    animation.duration = duration
    animation.fillMode = MCAMediaTimingFillMode.forwards
    animation.isRemovedOnCompletion = false

    return animation
}
