import Swift_CAAnimation_Closure

public class AnimationProducer {

	let sceneLayer: CALayer

	public required init(layer: CALayer) {
		sceneLayer = layer
	}

	public func addAnimation(animation: Animatable) {
		animation.shape?.animating = true

		switch animation.type {
		case .Unknown:
			return
		case .AffineTransformation:
			addTransformAnimation(animation)
		}
	}

	private func addTransformAnimation(animation: Animatable) {
		guard let transformAnimation = animation as? TransformAnimation else {
			return
		}

		guard let shape = animation.shape else {
			return
		}

		// Initial state
		let cgInitialTransform = transfomToCG(shape.pos)
		let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
		let initRect = CGRectApplyAffineTransform(rect, cgInitialTransform)
		let initScaleX = initRect.width
		let initScaleY = initRect.height

		// Creating proper animation
		var generatedAnimation: CAAnimation?

		if let start = transformAnimation.start, final = transformAnimation.final {
			generatedAnimation = transformAnimationByValues(start, finalValue: final, duration: animation.getDuration())
		} else if let valueFunc = transformAnimation.vFunc {
			generatedAnimation = transformAnimationByFunc(valueFunc, duration: animation.getDuration())
		} else {
			return
		}

		guard let generatedAnim = generatedAnimation else {
			return
		}

		generatedAnim.autoreverses = animation.autoreverses
		generatedAnim.repeatCount = Float(animation.repeatCount)

		// Creating animated layer
		let layer = ShapeLayer()
		// layer.backgroundColor = UIColor.greenColor().CGColor
		// layer.borderWidth = 1.0
		// layer.borderColor = UIColor.blueColor().CGColor

		unowned let uSelf = self

		generatedAnim.completion = { finished in
			if !finished {
				return
			}

			layer.removeFromSuperlayer()
			animation.shape?.animating = false
			uSelf.sceneLayer.setNeedsDisplay()
		}

		if let shapeBounds = shape.bounds() {
			let cgRect = shapeBounds.cgRect()
			let origFrame = CGRectMake(0.0, 0.0,
				cgRect.width + cgRect.origin.x,
				cgRect.height + cgRect.origin.y)

			// layer.frame = origFrame
			layer.frame = CGRectApplyAffineTransform(origFrame, cgInitialTransform)
			layer.renderTransform = CGAffineTransformMakeScale(initScaleX, initScaleY)
		}

		layer.shape = shape
		layer.setNeedsDisplay()

		sceneLayer.addSublayer(layer)
		layer.addAnimation(generatedAnim, forKey: "flying")
	}
}

func transfomToCG(transform: Transform) -> CGAffineTransform {
	return CGAffineTransformMake(
		CGFloat(transform.m11),
		CGFloat(transform.m12),
		CGFloat(transform.m21),
		CGFloat(transform.m22),
		CGFloat(transform.dx),
		CGFloat(transform.dy))
}

private func transformAnimationByValues(startValue: Transform, finalValue: Transform, duration: Double) -> CAAnimation {

	let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)

	let cgTransformStart = transfomToCG(startValue)
	let cgTransformFinal = transfomToCG(finalValue)

	// Small workaround

	let startRect = CGRectApplyAffineTransform(rect, cgTransformStart)
	let finalRect = CGRectApplyAffineTransform(rect, cgTransformFinal)

	let startX = startRect.origin.x
	let startY = startRect.origin.y
	let finalX = finalRect.origin.x
	let finalY = finalRect.origin.y
	let startScaleX = startRect.width
	let startScaleY = startRect.height
	let finalScaleX = finalRect.width
	let finalScaleY = finalRect.height

	let scaleX = CABasicAnimation(keyPath: "transform.scale.x")
	scaleX.fromValue = startScaleX
	scaleX.toValue = finalScaleX
	scaleX.duration = duration

	let scaleY = CABasicAnimation(keyPath: "transform.scale.y")
	scaleY.fromValue = startScaleY
	scaleY.toValue = finalScaleY
	scaleY.duration = duration

	let translationX = CABasicAnimation(keyPath: "transform.translation.x")
	translationX.fromValue = startX
	translationX.toValue = finalX
	translationX.duration = duration

	let translationY = CABasicAnimation(keyPath: "transform.translation.y")
	translationY.fromValue = startY
	translationY.toValue = finalY
	translationY.duration = duration

	let group = CAAnimationGroup()
	group.animations = [translationX, translationY, scaleX, scaleY]
	group.duration = duration

	return group
}

private func transformAnimationByFunc(valueFunc: (Double) -> Transform, duration: Double) -> CAAnimation {

	var scaleXValues = [CGFloat]()
	var scaleYValues = [CGFloat]()
	var xValues = [CGFloat]()
	var yValues = [CGFloat]()
	var timeValues = [Double]()

	let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)

	for t in 0.0.stride(to: 1.0, by: 0.05) {

		let value = valueFunc(t)
		let cgTransform = transfomToCG(value)
		let transformedRect = CGRectApplyAffineTransform(rect, cgTransform)

		timeValues.append(t)
		xValues.append(transformedRect.origin.x)
		yValues.append(transformedRect.origin.y)
		scaleXValues.append(transformedRect.width)
		scaleYValues.append(transformedRect.height)
	}

	let xAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
	xAnimation.duration = duration
	xAnimation.values = xValues
	xAnimation.keyTimes = timeValues

	let yAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
	yAnimation.duration = duration
	yAnimation.values = yValues
	yAnimation.keyTimes = timeValues

	let scaleXAnimation = CAKeyframeAnimation(keyPath: "transform.scale.x")
	scaleXAnimation.duration = duration
	scaleXAnimation.values = scaleXValues
	scaleXAnimation.keyTimes = timeValues

	let scaleYAnimation = CAKeyframeAnimation(keyPath: "transform.scale.y")
	scaleYAnimation.duration = duration
	scaleYAnimation.values = scaleYValues
	scaleYAnimation.keyTimes = timeValues

	let group = CAAnimationGroup()
	group.animations = [xAnimation, yAnimation, scaleXAnimation, scaleYAnimation]
	group.duration = duration

	return group
}
