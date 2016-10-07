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

	generatedAnim.autoreverses = animation.autoreverses
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

	var scaleXValues = [CGFloat]()
	var scaleYValues = [CGFloat]()
	var xValues = [CGFloat]()
	var yValues = [CGFloat]()
	var rotationValues = [CGFloat]()
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

		let dx = value.dx
		let dy = value.dy
		let a = value.m11
		let b = value.m12
		let c = value.m21
		let d = value.m22

		let sx = a / fabs(a) * sqrt(a * a + b * b)
		let sy = d / fabs(d) * sqrt(c * c + d * d)
		let angle = atan2(b, a)

		timeValues.append(dt)
		xValues.append(CGFloat(dx))
		yValues.append(CGFloat(dy))
		scaleXValues.append(CGFloat(sx))
		scaleYValues.append(CGFloat(sy))
		rotationValues.append(CGFloat(angle))
	}

	let xAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
	xAnimation.duration = duration
	xAnimation.values = xValues
	xAnimation.keyTimes = timeValues as [NSNumber]?

	let yAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
	yAnimation.duration = duration
	yAnimation.values = yValues
	yAnimation.keyTimes = timeValues as [NSNumber]?

	let scaleXAnimation = CAKeyframeAnimation(keyPath: "transform.scale.x")
	scaleXAnimation.duration = duration
	scaleXAnimation.values = scaleXValues
	scaleXAnimation.keyTimes = timeValues as [NSNumber]?

	let scaleYAnimation = CAKeyframeAnimation(keyPath: "transform.scale.y")
	scaleYAnimation.duration = duration
	scaleYAnimation.values = scaleYValues
	scaleYAnimation.keyTimes = timeValues as [NSNumber]?

	let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
	rotationAnimation.duration = duration
	rotationAnimation.values = rotationValues
	rotationAnimation.keyTimes = timeValues as [NSNumber]?

	let group = CAAnimationGroup()
	group.fillMode = kCAFillModeForwards
	group.isRemovedOnCompletion = false

	group.animations = [scaleXAnimation, scaleYAnimation, rotationAnimation, xAnimation, yAnimation]
	group.duration = duration

	return group
}

func fixedAngle(_ angle: CGFloat) -> CGFloat {
	return angle > -0.0000000000000000000000001 ? angle : CGFloat(2.0 * M_PI) + angle
}
