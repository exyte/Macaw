
import UIKit

func addOpacityAnimation(_ animation: BasicAnimation, sceneLayer: CALayer, animationCache: AnimationCache, completion: @escaping (() -> ())) {
	guard let opacityAnimation = animation as? OpacityAnimation else {
		return
	}

	guard let node = animation.node else {
		return
	}

	// Creating proper animation
	let generatedAnimation = opacityAnimationByFunc(opacityAnimation.getVFunc(), duration: animation.getDuration(), fps: opacityAnimation.logicalFps)
	generatedAnimation.repeatCount = Float(animation.repeatCount)
	generatedAnimation.timingFunction = caTimingFunction(animation.easing)

	generatedAnimation.completion = { finished in

		animationCache.freeLayer(node)

        if !animation.manualStop {
            animation.progress = 1.0
            node.opacityVar.value = opacityAnimation.getVFunc()(1.0)
        } else {
            node.opacityVar.value = opacityAnimation.getVFunc()(animation.progress)
        }

		animation.completion?()

		if !finished {
			animationRestorer.addRestoreClosure(completion)
			return
		}

		completion()
	}

	generatedAnimation.progress = { progress in

		let t = Double(progress)
		node.opacityVar.value = opacityAnimation.getVFunc()(t)

		animation.progress = t
		animation.onProgressUpdate?(t)
	}

	let layer = animationCache.layerForNode(node, animation: animation)
	layer.add(generatedAnimation, forKey: animation.ID)
	animation.removeFunc = {
		layer.removeAnimation(forKey: animation.ID)
	}
}

func opacityAnimationByFunc(_ valueFunc: (Double) -> Double, duration: Double, fps: UInt) -> CAAnimation {

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

		let value = valueFunc(dt)
		opacityValues.append(value)
		timeValues.append(dt)
	}

	let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
	opacityAnimation.fillMode = kCAFillModeForwards
	opacityAnimation.isRemovedOnCompletion = false

	opacityAnimation.duration = duration
	opacityAnimation.values = opacityValues
	opacityAnimation.keyTimes = timeValues as [NSNumber]?

	return opacityAnimation
}
