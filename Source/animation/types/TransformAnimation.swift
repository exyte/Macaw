import RxSwift

public class TransformAnimation: Animation<Transform> {

	public convenience init(animatedNode: Node, observableValue: Variable<Transform>, startValue: Transform, finalValue: Transform, animationDuration: Double, fps: UInt = 30) {

		let interpolationFunc = { (t: Double) -> Transform in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(animatedNode: animatedNode, observableValue: observableValue, valueFunc: interpolationFunc, animationDuration: animationDuration, fps: fps)
	}

	public init(animatedNode: Node, observableValue: Variable<Transform>, valueFunc: (Double) -> Transform, animationDuration: Double, fps: UInt = 30) {
		super.init(observableValue: observableValue, valueFunc: valueFunc, animationDuration: animationDuration, fps: fps)
		type = .AffineTransformation
		node = animatedNode
	}
}