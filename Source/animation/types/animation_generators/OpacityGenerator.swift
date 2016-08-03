
import UIKit

func addOpacityAnimation(animation: Animatable, sceneLayer: CALayer) {
	guard let opacityAnimation = animation as? OpacityAnimation else {
		return
	}

	guard let node = animation.node else {
		return
	}

	// Creating proper animation
	let generatedAnimation = opacityAnimationByFunc(opacityAnimation.vFunc, duration: animation.getDuration(), fps: opacityAnimation.logicalFps)
	generatedAnimation.autoreverses = animation.autoreverses
	generatedAnimation.repeatCount = Float(animation.repeatCount)
	generatedAnimation.timingFunction = caTimingFunction(animation.timingFunction)

	generatedAnimation.completion = { finished in

		let reversed = opacityAnimation.autoreverses
		let count = opacityAnimation.repeatCount + 1

		if (reversed || count > 1) {
			animation.node?.opacityVar.value = opacityAnimation.vFunc(1.0)
		} else {
			animation.node?.opacityVar.value = opacityAnimation.vFunc(animation.progress)
		}

		animation.node?.animating = false
		animationCache.freeLayer(node)

		animation.completion?()
	}

	generatedAnimation.progress = { progress in
		animation.progress = Double(progress)
	}

	let layer = animationCache.layerForNode(node)
	layer.addAnimation(generatedAnimation, forKey: animation.ID)
	animation.removeFunc = {
		layer.removeAnimationForKey(animation.ID)
	}
}

func opacityAnimationByFunc(valueFunc: (Double) -> Double, duration: Double, fps: UInt) -> CAAnimation {

	var opacityValues = [Double]()
	var timeValues = [Double]()

	let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)

	let step = 1.0 / (duration * Double(fps))
	for t in 0.0.stride(to: 1.0, by: step) {

		let value = valueFunc(t)
		opacityValues.append(value)
	}

	let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
	opacityAnimation.duration = duration
	opacityAnimation.values = opacityValues
	opacityAnimation.keyTimes = timeValues

	return opacityAnimation
}
