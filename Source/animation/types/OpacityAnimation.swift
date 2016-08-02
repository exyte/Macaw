
import RxSwift

public class OpacityAnimation: Animation<Double> {

	public convenience init(animatedNode: Node, observableValue: Variable<Double>, startValue: Double, finalValue: Double, animationDuration: Double, fps: UInt = 30) {

		let interpolationFunc = { (t: Double) -> Double in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(animatedNode: animatedNode, observableValue: observableValue, valueFunc: interpolationFunc, animationDuration: animationDuration, fps: fps)
	}

	public init(animatedNode: Node, observableValue: Variable<Double>, valueFunc: (Double) -> Double, animationDuration: Double, fps: UInt = 30) {
		super.init(observableValue: observableValue, valueFunc: valueFunc, animationDuration: animationDuration, fps: fps)
		type = .Opacity
		node = animatedNode
	}
}