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

func addPathAnimation(_ animation: BasicAnimation, sceneLayer: CALayer, animationCache: AnimationCache?, completion: @escaping (() -> Void)) {

    guard let nodeId = animation.nodeId, let shape = Node.nodeBy(id: nodeId) as? Shape else {
        return
    }
    
    animation.nodeId = nodeId
    
    let duration = animation.autoreverses ? animation.getDuration() / 2.0 : animation.getDuration()
    
    guard let layer = animationCache?.layerForNode(shape, animation: animation, shouldRenderContent: false) else {
        return
    }
    
    // Creating proper animation
    let generatedAnim = pathStrokeAnimation(from: 0.0, to: 1.0, duration: duration)
    
    generatedAnim.repeatCount = Float(animation.repeatCount)
    generatedAnim.timingFunction = caTimingFunction(animation.easing)
    generatedAnim.autoreverses = animation.autoreverses
    
    generatedAnim.completion = { finished in
        
//        if animation.manualStop {
//            animation.progress = 0.0
//            mutatingShape.form = morphingAnimation.getVFunc()(0.0)
//        } else if finished {
//            animation.progress = 1.0
//            mutatingShape.form = morphingAnimation.getVFunc()(1.0)
//        }
        
        animationCache?.freeLayer(shape)
        
        if  !animation.cycled &&
            !animation.manualStop {
            animation.completion?()
        }
        
        if !finished {
            animationRestorer.addRestoreClosure(completion)
            return
        }
        
        completion()
    }
    
    generatedAnim.progress = { progress in
        
        let t = Double(progress)
        //mutatingShape.form = morphingAnimation.getVFunc()(t)
        
        animation.progress = t
        animation.onProgressUpdate?(t)
    }
    
    let cgPath = RenderUtils.toCGPath(shape.form).copy(using: &layer.renderTransform!)
    layer.path = cgPath
    
    // Stroke
    if let stroke = shape.stroke {
        if let color = stroke.fill as? Color {
            layer.strokeColor = RenderUtils.mapColor(color)
        } else {
            layer.strokeColor = MColor.black.cgColor
        }
        
        layer.lineWidth = CGFloat(stroke.width)
        layer.lineCap = RenderUtils.mapLineCapToString(stroke.cap)
        layer.lineJoin = RenderUtils.mapLineJoinToString(stroke.join)
        layer.lineDashPattern = stroke.dashes.map { NSNumber(value: $0) }
    } else {
        layer.strokeColor = MColor.black.cgColor
        layer.lineWidth = 1.0
    }
    
    // Fill
    if let color = shape.fill as? Color {
        layer.fillColor = RenderUtils.mapColor(color)
    } else {
        layer.fillColor = MColor.clear.cgColor
    }
        
    layer.add(generatedAnim, forKey: animation.ID)
    animation.removeFunc = {
        layer.removeAnimation(forKey: animation.ID)
    }
}

fileprivate func pathStrokeAnimation(from: Double, to: Double, duration: Double) -> CAAnimation {
    
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.fromValue = from
    animation.toValue = to
    animation.duration = duration
    animation.fillMode = kCAFillModeForwards
    animation.isRemovedOnCompletion = false
    
    return animation
}
