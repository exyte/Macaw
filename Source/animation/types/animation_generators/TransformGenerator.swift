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

    // Creating proper animation
    var generatedAnimation: CAAnimation?

    generatedAnimation = transformAnimationByFunc(node,
                                                  valueFunc: transformAnimation.getVFunc(),
                                                  duration: animation.getDuration(),
                                                  offset: animation.pausedProgress,
                                                  fps: transformAnimation.logicalFps)

    guard let generatedAnim = generatedAnimation else {
        return
    }

    generatedAnim.repeatCount = Float(animation.repeatCount)
    generatedAnim.timingFunction = caTimingFunction(animation.easing)

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

func transfomToCG(_ transform: Transform) -> CGAffineTransform {
    return CGAffineTransform(
        a: CGFloat(transform.m11),
        b: CGFloat(transform.m12),
        c: CGFloat(transform.m21),
        d: CGFloat(transform.m22),
        tx: CGFloat(transform.dx),
        ty: CGFloat(transform.dy))
}

func transformAnimationByFunc(_ node: Node, valueFunc: (Double) -> Transform, duration: Double, offset: Double, fps: UInt) -> CAAnimation {

    var transformValues = [CATransform3D]()
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

        timeValues.append(dt)
        let value = AnimationUtils.absoluteTransform(node, pos: valueFunc(offset + dt))
        let cgValue = CATransform3DMakeAffineTransform(value.toCG())
        transformValues.append(cgValue)
    }

    let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
    transformAnimation.duration = duration
    transformAnimation.values = transformValues
    transformAnimation.keyTimes = timeValues as [NSNumber]?
    transformAnimation.fillMode = kCAFillModeForwards
    transformAnimation.isRemovedOnCompletion = false

    return transformAnimation
}

func fixedAngle(_ angle: CGFloat) -> CGFloat {
    return angle > -0.0000000000000000000000001 ? angle : CGFloat(2.0 * Double.pi) + angle
}
