import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

func addTransformAnimation(_ animation: BasicAnimation, sceneLayer: CALayer, animationCache: AnimationCache?, completion: @escaping (() -> Void)) {
    guard let transformAnimation = animation as? TransformAnimation else {
        return
    }

    guard let nodeId = animation.nodeId, let node = Node.nodeBy(id: nodeId) else {
        return
    }

    if transformAnimation.easing === Easing.elasticInOut {
        fatalError("Transform animation can't have elastic easing, try using contentVar animation instead")
    }

    // Creating proper animation
    var generatedAnimation: CAAnimation?

    generatedAnimation = transformAnimationByFunc(transformAnimation,
                                                  duration: animation.getDuration(),
                                                  offset: animation.pausedProgress,
                                                  fps: transformAnimation.logicalFps)

    guard let generatedAnim = generatedAnimation else {
        return
    }

    generatedAnim.repeatCount = Float(animation.repeatCount)
    generatedAnim.timingFunction = animation.easing.caTimingFunction()
    generatedAnim.autoreverses = animation.autoreverses

    generatedAnim.completion = { finished in

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

        animationCache?.freeLayer(node)

        if !animation.cycled &&
            !animation.manualStop &&
            !animation.paused {
            animation.completion?()
        }

        completion()
    }

    generatedAnim.progress = { progress in

        let t = Double(progress)
        node.placeVar.value = transformAnimation.getVFunc()(t)

        animation.progress = t
        animation.onProgressUpdate?(t)
    }

    if let layer = animationCache?.layerForNode(node, animation: animation) {
        let animationId = animation.ID
        layer.add(generatedAnim, forKey: animationId)
        animation.removeFunc = { [weak layer] in
            layer?.removeAnimation(forKey: animationId)
        }
    }
}

func transformAnimationByFunc(_ animation: TransformAnimation, duration: Double, offset: Double, fps: UInt) -> CAAnimation {

    let group = CAAnimationGroup()
    group.duration = duration
    group.fillMode = kCAFillModeForwards
    group.isRemovedOnCompletion = false

    let fromTransform = animation.getVFunc()(0.0).toCG()
    let toTransform = animation.getVFunc()(animation.autoreverses ? 0.5 : 1.0).toCG()

    let transformAnimation = CABasicAnimation(keyPath: "transform")
    transformAnimation.duration = duration
    transformAnimation.fromValue = NSValue(caTransform3D: CATransform3DMakeAffineTransform(fromTransform))
    transformAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeAffineTransform(toTransform))
    transformAnimation.fillMode = kCAFillModeForwards
    transformAnimation.isRemovedOnCompletion = false

    group.animations = [transformAnimation]

    if let trajectory = animation.trajectory {
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.calculationMode = kCAAnimationPaced
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.path = trajectory.toCGPath()

        group.animations?.append(pathAnimation)
    }

    return group
}
