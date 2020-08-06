import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

func addOpacityAnimation(_ animation: BasicAnimation, _ context: AnimationContext, sceneLayer: CALayer?, completion: @escaping (() -> Void)) {
    guard let opacityAnimation = animation as? OpacityAnimation else {
        return
    }

    guard let node = animation.node, let renderer = animation.nodeRenderer else {
        return
    }

    let transactionsDisabled = CATransaction.disableActions()
    CATransaction.setDisableActions(true)

    // Creating proper animation
    let generatedAnimation = opacityAnimationByFunc(opacityAnimation.getVFunc(),
                                                    duration: animation.getDuration(),
                                                    offset: animation.pausedProgress,
                                                    fps: opacityAnimation.logicalFps)
    generatedAnimation.repeatCount = Float(animation.repeatCount)
    generatedAnimation.timingFunction = caTimingFunction(animation.easing)

    generatedAnimation.progress = { progress in
        let t = Double(progress)
        animation.progress = t
        animation.onProgressUpdate?(t)
    }

    generatedAnimation.completion = { finished in

        if animation.paused {
            animation.pausedProgress += animation.progress
            node.opacityVar.value = opacityAnimation.getVFunc()(animation.pausedProgress)
        } else if animation.manualStop {
            animation.pausedProgress = 0.0
            animation.progress = 0.0
            node.opacityVar.value = opacityAnimation.getVFunc()(0.0)
        } else if finished {
            animation.pausedProgress = 0.0
            animation.progress = 1.0
            node.opacityVar.value = opacityAnimation.getVFunc()(1.0)
        }

        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        renderer.layer?.animationLayer.opacity = Float(node.opacity)
        CATransaction.commit()

        if !animation.paused {
            animation.removeFunc?()
        }

        renderer.freeLayer()

        if  !animation.cycled &&
                !animation.manualStop &&
                !animation.paused {
            animation.completion?()
        }

        completion()
    }

    let layer = AnimationUtils.layerForNodeRenderer(renderer, animation: animation)
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

func opacityAnimationByFunc(_ valueFunc: (Double) -> Double, duration: Double, offset: Double, fps: UInt) -> CAAnimation {

    var opacityValues = [Double]()
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

        let value = valueFunc(offset + dt)
        opacityValues.append(value)
        timeValues.append(dt)
    }

    let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
    opacityAnimation.fillMode = MCAMediaTimingFillMode.forwards
    opacityAnimation.isRemovedOnCompletion = false

    opacityAnimation.duration = duration
    opacityAnimation.values = opacityValues
    opacityAnimation.keyTimes = timeValues as [NSNumber]?

    return opacityAnimation
}
