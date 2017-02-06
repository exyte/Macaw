//
//  ShapeAnimationGenerator.swift
//  Pods
//
//  Created by Victor Sukochev on 03/02/2017.
//
//

import UIKit

func addShapeAnimation(_ animation: BasicAnimation, sceneLayer: CALayer, animationCache: AnimationCache, completion: @escaping (() -> ())) {
    guard let shapeAnimation = animation as? ShapeAnimation else {
        return
    }
    
    guard let shape = animation.node as? Shape else {
        return
    }
    
    let fromShape = shapeAnimation.getVFunc()(0.0)
    let toShape = shapeAnimation.getVFunc()(animation.autoreverses ? 0.5 : 1.0)
  
    let layer = animationCache.layerForNode(shape, animation: animation, shouldRenderContent: false)
    
    // Creating proper animation
    let generatedAnim = generateShapAnimation(
        from:fromShape,
        to:toShape,
        duration: animation.getDuration(),
        renderTransform: layer.renderTransform!)
    
    generatedAnim.repeatCount = Float(animation.repeatCount)
    generatedAnim.timingFunction = caTimingFunction(animation.easing)
    generatedAnim.autoreverses = animation.autoreverses
    
    generatedAnim.completion = { finished in
        
        if !animation.manualStop {
            animation.progress = 1.0
        }
        
        shape.form = toShape.form
        shape.stroke = toShape.stroke
        
        animationCache.freeLayer(shape)
        animation.completion?()
        
        if !finished {
            animationRestorer.addRestoreClosure(completion)
            return
        }
        
        completion()
    }
    
    generatedAnim.progress = { progress in
        
        let t = Double(progress)
        let currentShape = shapeAnimation.getVFunc()(t)
        shape.form = currentShape.form
        shape.stroke = currentShape.stroke
        
        animation.progress = t
        animation.onProgressUpdate?(t)
    }
    
    layer.path = RenderUtils.toCGPath(fromShape.form)
    
    // Stroke
    if let stroke = shape.stroke {
        if let color = stroke.fill as? Color {
            layer.strokeColor = RenderUtils.mapColor(color)
        } else {
            layer.strokeColor = UIColor.black.cgColor
        }
        
        layer.lineWidth = CGFloat(stroke.width)
        layer.lineCap = RenderUtils.mapLineCapToString(stroke.cap)
        layer.lineJoin = RenderUtils.mapLineJoinToString(stroke.join)
        layer.lineDashPattern = stroke.dashes.map{ NSNumber(value: $0)}
    } else {
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 1.0
    }
    
    // Fill
    if let color = shape.fill as? Color {
        layer.fillColor = RenderUtils.mapColor(color)
    } else {
        layer.fillColor = UIColor.clear.cgColor
    }
    
    layer.add(generatedAnim, forKey: animation.ID)
    animation.removeFunc = {
        layer.removeAnimation(forKey: animation.ID)
    }
}

fileprivate func generateShapAnimation(from:Shape, to: Shape, duration: Double, renderTransform: CGAffineTransform) -> CAAnimation {
    
    // Path
    var transform = renderTransform
    let fromPath = RenderUtils.toCGPath(from.form).copy(using: &transform)
    let toPath = RenderUtils.toCGPath(to.form).copy(using: &transform)
    
    let group = CAAnimationGroup()
    
    let pathAnimation = CABasicAnimation(keyPath: "path")
    pathAnimation.fromValue = fromPath
    pathAnimation.toValue = toPath
    pathAnimation.duration = duration
    
     group.animations = [pathAnimation]
    
    // Stroke
    if let fromStroke = from.stroke, let toStroke = to.stroke {
        // Line width
        let strokeWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        strokeWidthAnimation.fromValue = fromStroke.width
        strokeWidthAnimation.toValue = toStroke.width
        strokeWidthAnimation.duration = duration
        
        group.animations?.append(strokeWidthAnimation)
        
        // Line color
        if let fromColor = fromStroke.fill as? Color, let toColor = toStroke.fill as? Color{
            let strokeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
            strokeColorAnimation.fromValue = RenderUtils.mapColor(fromColor)
            strokeColorAnimation.toValue = RenderUtils.mapColor(toColor)
            strokeColorAnimation.duration = duration
            
            group.animations?.append(strokeColorAnimation)
        }
        
        let dashPatternAnimation = CABasicAnimation(keyPath: "lineDashPattern")
        dashPatternAnimation.fromValue = fromStroke.dashes
        dashPatternAnimation.toValue = toStroke.dashes
        dashPatternAnimation.duration = duration
        
        group.animations?.append(dashPatternAnimation)
    }
    
    
   
    group.duration = duration
    group.fillMode = kCAFillModeForwards
    group.isRemovedOnCompletion = false
    
    return group
}
