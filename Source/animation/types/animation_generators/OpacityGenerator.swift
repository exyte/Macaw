
import UIKit

func addOpacityAnimation(animation: Animatable, sceneLayer: CALayer) {
	guard let transformAnimation = animation as? OpacityAnimation else {
		return
	}

	guard let node = animation.node else {
		return
	}

	// Creating proper animation
	let generatedAnimation = opacityAnimationByFunc(transformAnimation.vFunc, duration: animation.getDuration(), fps: transformAnimation.logicalFps)
	generatedAnimation.autoreverses = animation.autoreverses
	generatedAnimation.repeatCount = Float(animation.repeatCount)
	generatedAnimation.timingFunction = caTimingFunction(animation.timingFunction)
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
