//
//  ShapeAnimationGenerator.swift
//  Pods
//
//  Created by Victor Sukochev on 03/02/2017.
//
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

func addShapeAnimation(_ animation: BasicAnimation, sceneLayer: CALayer, animationCache: AnimationCache?, completion: @escaping (() -> Void)) {
    guard let shapeAnimation = animation as? ShapeAnimation else {
        return
    }

    guard let nodeId = animation.nodeId, let shape = Node.nodeBy(id: nodeId) as? Shape else {
        return
    }

    let fromShape = shapeAnimation.getVFunc()(0.0)
    let toShape = shapeAnimation.getVFunc()(animation.autoreverses ? 0.5 : 1.0)
    let duration = animation.autoreverses ? animation.getDuration() / 2.0 : animation.getDuration()

    let mutatingShape = SceneUtils.shapeCopy(from: fromShape)
    nodesMap.replace(node: shape, to: mutatingShape)
    animationCache?.replace(original: shape, replacement: mutatingShape)

    guard let layer = animationCache?.layerForNode(mutatingShape, animation: animation, shouldRenderContent: false) else {
        return
    }

    // Creating proper animation
    let generatedAnim = generateShapeAnimation(
        from: mutatingShape,
        to: toShape,
        duration: duration,
        renderTransform: layer.renderTransform!)

    generatedAnim.repeatCount = Float(animation.repeatCount)
    generatedAnim.timingFunction = caTimingFunction(animation.easing)
    generatedAnim.autoreverses = animation.autoreverses

    generatedAnim.completion = { finished in

        animation.progress = animation.manualStop ? 0.0 : 1.0

        if !animation.autoreverses && finished {
            mutatingShape.form = toShape.form
            mutatingShape.stroke = toShape.stroke
            mutatingShape.fill = toShape.fill
        }

        if !finished {
            animation.progress = 0.0
            mutatingShape.form = fromShape.form
            mutatingShape.stroke = fromShape.stroke
            mutatingShape.fill = fromShape.fill
        }

        animationCache?.freeLayer(mutatingShape)

        if !animation.cycled && !animation.manualStop {
            animation.completion?()
        }

        completion()
    }

    generatedAnim.progress = { progress in

        let t = Double(progress)

        if !animation.autoreverses {
            let currentShape = shapeAnimation.getVFunc()(t)
            mutatingShape.place = currentShape.place
            mutatingShape.opaque = currentShape.opaque
            mutatingShape.opacity = currentShape.opacity
            mutatingShape.clip = currentShape.clip
            mutatingShape.mask = currentShape.mask
            mutatingShape.effect = currentShape.effect
            mutatingShape.form = currentShape.form
            mutatingShape.stroke = currentShape.stroke
            mutatingShape.fill = currentShape.fill
        }

        animation.progress = t
        animation.onProgressUpdate?(t)
    }

    layer.path = fromShape.form.toCGPath()

    // Stroke
    if let stroke = shape.stroke {
        if let color = stroke.fill as? Color {
            layer.strokeColor = color.toCG()
        } else {
            layer.strokeColor = MColor.black.cgColor
        }

        layer.lineWidth = CGFloat(stroke.width)
        layer.lineCap = MCAShapeLayerLineCap.mapToGraphics(model: stroke.cap)
        layer.lineJoin = MCAShapeLayerLineJoin.mapToGraphics(model: stroke.join)
        layer.lineDashPattern = stroke.dashes.map { NSNumber(value: $0) }
    } else if shape.fill == nil {
        layer.strokeColor = MColor.black.cgColor
        layer.lineWidth = 1.0
    }

    // Fill
    if let color = shape.fill as? Color {
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

fileprivate func generateShapeAnimation(from: Shape, to: Shape, duration: Double, renderTransform: CGAffineTransform) -> CAAnimation {

    let group = CAAnimationGroup()

    // Shape
    // Path
    var transform = renderTransform
    let fromPath = from.form.toCGPath().copy(using: &transform)
    let toPath = to.form.toCGPath().copy(using: &transform)

    let pathAnimation = CABasicAnimation(keyPath: "path")
    pathAnimation.fromValue = fromPath
    pathAnimation.toValue = toPath
    pathAnimation.duration = duration

    group.animations = [pathAnimation]

    // Transform
    let scaleAnimation = CABasicAnimation(keyPath: "transform")
    scaleAnimation.duration = duration
    let view = nodesMap.getView(from)
    scaleAnimation.fromValue = CATransform3DMakeAffineTransform(AnimationUtils.absolutePosition(from, view: view).toCG())
    scaleAnimation.toValue = CATransform3DMakeAffineTransform(AnimationUtils.absolutePosition(to, view: view).toCG())

    group.animations?.append(scaleAnimation)

    // Fill
    let fromFillColor = from.fill as? Color ?? Color.clear
    let toFillColor = to.fill as? Color ?? Color.clear

    if fromFillColor != toFillColor {
        let fillAnimation = CABasicAnimation(keyPath: "fillColor")
        fillAnimation.fromValue = fromFillColor.toCG()
        fillAnimation.toValue = toFillColor.toCG()
        fillAnimation.duration = duration

        group.animations?.append(fillAnimation)
    }

    // Stroke
    let fromStroke = from.stroke ?? Stroke(fill: Color.black, width: 1.0)
    let toStroke = to.stroke ?? Stroke(fill: Color.black, width: 1.0)

    // Line width
    if fromStroke.width != toStroke.width {
        let strokeWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        strokeWidthAnimation.fromValue = fromStroke.width
        strokeWidthAnimation.toValue = toStroke.width
        strokeWidthAnimation.duration = duration

        group.animations?.append(strokeWidthAnimation)
    }

    // Line color
    let fromStrokeColor = fromStroke.fill as? Color ?? Color.black
    let toStrokeColor = toStroke.fill as? Color ?? Color.black

    if fromStrokeColor != toStrokeColor {
        let strokeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
        strokeColorAnimation.fromValue = fromStrokeColor.toCG()
        strokeColorAnimation.toValue = toStrokeColor.toCG()
        strokeColorAnimation.duration = duration

        group.animations?.append(strokeColorAnimation)
    }

    // Dash pattern
    if fromStroke.dashes != toStroke.dashes {
        let dashPatternAnimation = CABasicAnimation(keyPath: "lineDashPattern")
        dashPatternAnimation.fromValue = fromStroke.dashes
        dashPatternAnimation.toValue = toStroke.dashes
        dashPatternAnimation.duration = duration

        group.animations?.append(dashPatternAnimation)
    }

    // Group
    group.duration = duration
    group.fillMode = MCAMediaTimingFillMode.forwards
    group.isRemovedOnCompletion = false

    return group
}
