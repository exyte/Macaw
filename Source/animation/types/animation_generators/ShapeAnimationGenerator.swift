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

func addShapeAnimation(_ animation: BasicAnimation, _ context: AnimationContext, sceneLayer: CALayer?, completion: @escaping (() -> Void)) {
    guard let shapeAnimation = animation as? ShapeAnimation else {
        return
    }

    guard let shape = animation.node as? Shape, let renderer = animation.nodeRenderer else {
        return
    }

    let transactionsDisabled = CATransaction.disableActions()
    CATransaction.setDisableActions(true)

    guard let fromShape = SceneUtils.copyNode(shapeAnimation.getVFunc()(0.0)) as? Shape else {
        return
    }
    let toShape = shapeAnimation.getVFunc()(animation.autoreverses ? 0.5 : 1.0)
    let duration = animation.autoreverses ? animation.getDuration() / 2.0 : animation.getDuration()

    let layer = AnimationUtils.layerForNodeRenderer(renderer, animation: animation, shouldRenderContent: false)

    // Creating proper animation
    let generatedAnimation = generateShapeAnimation(context,
                                                    from: fromShape,
                                                    to: toShape,
                                                    animation: shapeAnimation,
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

        animation.progress = animation.manualStop ? 0.0 : 1.0

        if !animation.autoreverses && finished {
            if fromShape.form != toShape.form {
                shape.form = toShape.form
            }
            if fromShape.stroke != toShape.stroke {
                shape.stroke = toShape.stroke
            }
            if fromShape.fill != toShape.fill {
                shape.fill = toShape.fill
            }
        }

        if !finished {
            animation.progress = 0.0
            if fromShape.form != toShape.form {
                shape.form = toShape.form
            }
            if fromShape.stroke != toShape.stroke {
                shape.stroke = toShape.stroke
            }
            if fromShape.fill != toShape.fill {
                shape.fill = toShape.fill
            }
        }

        renderer.freeLayer()

        if !animation.cycled && !animation.manualStop {
            animation.completion?()
        }

        completion()
    }

    layer.path = fromShape.form.toCGPath()
    layer.setupStrokeAndFill(fromShape)

    let animationId = animation.ID
    layer.add(generatedAnimation, forKey: animationId)
    animation.removeFunc = { [weak layer] in
        layer?.removeAnimation(forKey: animationId)
    }

    if !transactionsDisabled {
        CATransaction.commit()
    }
}

fileprivate func generateShapeAnimation(_ context: AnimationContext, from: Shape, to: Shape, animation: ShapeAnimation, duration: Double) -> CAAnimation {

    let group = CAAnimationGroup()

    // Path
    let fromPath = from.form.toCGPath()
    let toPath = to.form.toCGPath()

    let pathAnimation = CABasicAnimation(keyPath: "path")
    pathAnimation.fromValue = fromPath
    pathAnimation.toValue = toPath
    pathAnimation.duration = duration

    group.animations = [pathAnimation]

    // Transform
    let transformAnimation = CABasicAnimation(keyPath: "transform")
    transformAnimation.duration = duration
    transformAnimation.fromValue = CATransform3DMakeAffineTransform(from.place.toCG())
    transformAnimation.toValue = CATransform3DMakeAffineTransform(to.place.toCG())

    group.animations?.append(transformAnimation)

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

    // Dash offset
    if fromStroke.offset != toStroke.offset {
        let dashOffsetAnimation = CABasicAnimation(keyPath: "lineDashPhase")
        dashOffsetAnimation.fromValue = fromStroke.offset
        dashOffsetAnimation.toValue = toStroke.offset
        dashOffsetAnimation.duration = duration

        group.animations?.append(dashOffsetAnimation)
    }

    // Group
    group.duration = duration
    group.fillMode = MCAMediaTimingFillMode.forwards
    group.isRemovedOnCompletion = false

    return group
}
