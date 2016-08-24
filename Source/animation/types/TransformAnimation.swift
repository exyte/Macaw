import RxSwift

public class TransformAnimation: Animation<Transform> {

	public convenience init(animatedNode: Node, startValue: Transform, finalValue: Transform, animationDuration: Double, fps: UInt = 30) {

		let interpolationFunc = { (t: Double) -> Transform in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, fps: fps)
	}

	public init(animatedNode: Node, valueFunc: (Double) -> Transform, animationDuration: Double, fps: UInt = 30) {
		super.init(observableValue: animatedNode.posVar, valueFunc: valueFunc, animationDuration: animationDuration, fps: fps)
		type = .AffineTransformation
		node = animatedNode
	}
}