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
        shape.fill = toShape.fill
        
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
        shape.fill = currentShape.fill
        
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
    
    let group = CAAnimationGroup()
    
    // Shape
    // Path
    var transform = renderTransform
    let fromPath = RenderUtils.toCGPath(from.form).copy(using: &transform)
    let toPath = RenderUtils.toCGPath(to.form).copy(using: &transform)
    
    let pathAnimation = CABasicAnimation(keyPath: "path")
    pathAnimation.fromValue = fromPath
    pathAnimation.toValue = toPath
    pathAnimation.duration = duration
    
     group.animations = [pathAnimation]
    
    // Fill
    let fromFillColor = from.fill as? Color ?? Color.clear
    let toFillColor = to.fill as? Color ?? Color.clear
    
    let fillAnimation = CABasicAnimation(keyPath: "fillColor")
    fillAnimation.fromValue = RenderUtils.mapColor(fromFillColor)
    fillAnimation.toValue = RenderUtils.mapColor(toFillColor)
    fillAnimation.duration = duration
    
    group.animations?.append(fillAnimation)
    
    
    // Stroke
    let fromStroke = from.stroke ?? Stroke(fill: Color.black, width: 1.0)
    let toStroke = to.stroke ?? Stroke(fill: Color.black, width: 1.0)
    
    // Line width
    let strokeWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
    strokeWidthAnimation.fromValue = fromStroke.width
    strokeWidthAnimation.toValue = toStroke.width
    strokeWidthAnimation.duration = duration
    
    group.animations?.append(strokeWidthAnimation)
    
        // Line color
    let fromStrokeColor = fromStroke.fill as? Color ?? Color.black
    let toStrokeColor = toStroke.fill as? Color ?? Color.black
    
    let strokeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
    strokeColorAnimation.fromValue = RenderUtils.mapColor(fromStrokeColor)
    strokeColorAnimation.toValue = RenderUtils.mapColor(toStrokeColor)
    strokeColorAnimation.duration = duration
    
    group.animations?.append(strokeColorAnimation)
    
    
    
    // Dash pattern
    let dashPatternAnimation = CABasicAnimation(keyPath: "lineDashPattern")
    dashPatternAnimation.fromValue = fromStroke.dashes
    dashPatternAnimation.toValue = toStroke.dashes
    dashPatternAnimation.duration = duration
    
    group.animations?.append(dashPatternAnimation)
    
    // Group
    group.duration = duration
    group.fillMode = kCAFillModeForwards
    group.isRemovedOnCompletion = false
    
    return group
}
