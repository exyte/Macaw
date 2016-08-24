
import RxSwift

public class OpacityAnimation: Animation<Double> {

	public convenience init(animatedNode: Node, startValue: Double, finalValue: Double, animationDuration: Double, autostart: Bool = false, fps: UInt = 30) {

		let interpolationFunc = { (t: Double) -> Double in
			return startValue.interpolate(finalValue, progress: t)
		}

		self.init(animatedNode: animatedNode, valueFunc: interpolationFunc, animationDuration: animationDuration, autostart: autostart, fps: fps)
	}

	public init(animatedNode: Node, valueFunc: (Double) -> Double, animationDuration: Double, autostart: Bool = false, fps: UInt = 30) {
		super.init(observableValue: animatedNode.opacityVar, valueFunc: valueFunc, animationDuration: animationDuration, autostart: autostart, fps: fps)
		type = .Opacity
		node = animatedNode
	}
}