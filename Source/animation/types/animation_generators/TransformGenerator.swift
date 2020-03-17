import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

func addTransformAnimation(_ animation: BasicAnimation, _ context: AnimationContext, sceneLayer: CALayer?, completion: @escaping (() -> Void)) {
    guard let transformAnimation = animation as? TransformAnimation else {
        return
    }

    if transformAnimation.trajectory != nil && transformAnimation.easing === Easing.elasticInOut {
        fatalError("Transform animation with trajectory can't have elastic easing, try using contentVar animation instead")
    }

    guard let node = animation.node, let renderer = animation.nodeRenderer else {
        return
    }

    let transactionsDisabled = CATransaction.disableActions()
    CATransaction.setDisableActions(true)

    let layer = AnimationUtils.layerForNodeRenderer(renderer, animation: animation, shouldRenderContent: true)

    // Creating proper animation
    let generatedAnimation = transformAnimationByFunc(transformAnimation,
                                                      context,
                                                      duration: animation.getDuration(),
                                                      offset: animation.pausedProgress,
                                                      fps: transformAnimation.logicalFps)

    generatedAnimation.repeatCount = Float(animation.repeatCount)

    generatedAnimation.progress = { progress in
        let t = Double(progress)
        animation.progress = t
        animation.onProgressUpdate?(t)
    }

    generatedAnimation.completion = { finished in

        if animation.paused {
            animation.pausedProgress += animation.progress
            node.placeVar.value = transformAnimation.getVFunc()(animation.pausedProgress)
        } else if animation.manualStop {
            animation.pausedProgress = 0.0
            animation.progress = 0.0
            node.placeVar.value = transformAnimation.getVFunc()(0.0)
        } else if finished {
            animation.pausedProgress = 0.0
            animation.progress = 1.0
            node.placeVar.value = transformAnimation.getVFunc()(1.0)
        }

        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        renderer.layer?.animationLayer.transform = CATransform3DMakeAffineTransform(node.place.toCG())
        CATransaction.commit()

        if !animation.paused {
            animation.removeFunc?()
        }

        renderer.freeLayer()

        if !animation.cycled &&
            !animation.manualStop &&
            !animation.paused {
            animation.completion?()
        }

        completion()
    }

    let animationId = animation.ID
    layer.add(generatedAnimation, forKey: animationId)
    animation.removeFunc = { [weak layer] in
        node.animations.removeAll { $0 === animation }
        layer?.removeAnimation(forKey: animationId)
    }

    if !transactionsDisabled {
        CATransaction.commit()
    }
}

func transformAnimationByFunc(_ animation: TransformAnimation, _ context: AnimationContext, duration: Double, offset: Double, fps: UInt) -> CAAnimation {

    let valueFunc = animation.getVFunc()

    if let trajectory = animation.trajectory {
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.timingFunction = caTimingFunction(animation.easing)
        pathAnimation.duration = duration / 2
        pathAnimation.autoreverses = animation.autoreverses
        pathAnimation.fillMode = MCAMediaTimingFillMode.forwards
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.path = trajectory.toCGPath()

        return pathAnimation
    }

    var transformValues = [CATransform3D]()
    let step = 1.0 / (duration * Double(fps))
    var tValue = Array(stride(from: 0.0, to: 1.0, by: step))
    tValue.append(1.0)
    for t in tValue {
        let progress = animation.easing.progressFor(time: t)
        let value = valueFunc(offset + progress)
        let cgValue = CATransform3DMakeAffineTransform(value.toCG())
        transformValues.append(cgValue)
    }

    let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
    transformAnimation.duration = duration
    transformAnimation.values = transformValues
    transformAnimation.fillMode = MCAMediaTimingFillMode.forwards
    transformAnimation.isRemovedOnCompletion = false

    return transformAnimation
}
