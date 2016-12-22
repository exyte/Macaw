import UIKit

func addTransformAnimation(_ animation: BasicAnimation, sceneLayer: CALayer, animationCache: AnimationCache, completion: @escaping (() -> ())) {
	guard let transformAnimation = animation as? TransformAnimation else {
		return
	}

	guard let node = animation.node else {
		return
	}

	// Creating proper animation
	var generatedAnimation: CAAnimation?

	generatedAnimation = transformAnimationByFunc(node, valueFunc: transformAnimation.getVFunc(), duration: animation.getDuration(), fps: transformAnimation.logicalFps)

	guard let generatedAnim = generatedAnimation else {
		return
	}

	// generatedAnim.autoreverses = animation.autoreverses
	generatedAnim.repeatCount = Float(animation.repeatCount)
	generatedAnim.timingFunction = caTimingFunction(animation.easing)

	generatedAnim.completion = { finished in

        if !animation.manualStop {
            animation.progress = 1.0
            node.placeVar.value = transformAnimation.getVFunc()(1.0)
        } else {
            node.placeVar.value = transformAnimation.getVFunc()(animation.progress)
        }

		animationCache.freeLayer(node)
		animation.completion?()

		if !finished {
			animationRestorer.addRestoreClosure(completion)
			return
		}

		completion()
	}

	generatedAnim.progress = { progress in

		let t = Double(progress)
		node.placeVar.value = transformAnimation.getVFunc()(t)

		animation.progress = t
		animation.onProgressUpdate?(t)
	}

	let layer = animationCache.layerForNode(node, animation: animation)

	layer.add(generatedAnim, forKey: animation.ID)
	animation.removeFunc = {
		layer.removeAnimation(forKey: animation.ID)
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

func transformAnimationByFunc(_ node: Node, valueFunc: (Double) -> Transform, duration: Double, fps: UInt) -> CAAnimation {

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
        
		let value = AnimationUtils.absoluteTransform(node, pos: valueFunc(dt))
        let cgValue = CATransform3DMakeAffineTransform(RenderUtils.mapTransform(value))
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
	return angle > -0.0000000000000000000000001 ? angle : CGFloat(2.0 * M_PI) + angle
}
