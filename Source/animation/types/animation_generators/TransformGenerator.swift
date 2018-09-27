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

    if transformAnimation.trajectory != nil && transformAnimation.easing === Easing.elasticInOut {
        fatalError("Transform animation with trajectory can't have elastic easing, try using contentVar animation instead")
    }

    node.placeVar.value = transformAnimation.getVFunc()(0.0)

    // Creating proper animation
    var generatedAnimation: CAAnimation?

    generatedAnimation = transformAnimationByFunc(transformAnimation,
                                                  node: node,
                                                  duration: animation.getDuration(),
                                                  offset: animation.pausedProgress,
                                                  fps: transformAnimation.logicalFps)

    guard let generatedAnim = generatedAnimation else {
        return
    }

    generatedAnim.repeatCount = Float(animation.repeatCount)

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

func transformAnimationByFunc(_ animation: TransformAnimation, node: Node, duration: Double, offset: Double, fps: UInt) -> CAAnimation {

    let valueFunc = animation.getVFunc()
    let view = nodesMap.getView(node)

    if let trajectory = animation.trajectory {
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.timingFunction = caTimingFunction(animation.easing)
        pathAnimation.duration = duration / 2
        pathAnimation.autoreverses = animation.autoreverses
        let value = AnimationUtils.absoluteTransform(node, pos: valueFunc(0), view: view)
        pathAnimation.values = [NSValue(caTransform3D: CATransform3DMakeAffineTransform(value.toCG()))]
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
        let value = AnimationUtils.absoluteTransform(node, pos: valueFunc(offset + progress), view: view)
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
