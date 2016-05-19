import RxSwift

public class TransformAnimation: Animation<Transform> {

	public required init(animatedShape: Group, observableValue: Variable<Transform>, startValue: Transform, finalValue: Transform, animationDuration: Double) {
		super.init(observableValue: observableValue, animationDuration: animationDuration)
		type = .AffineTransformation
		shape = animatedShape
		start = startValue
		final = finalValue
	}

	public required init(animatedShape: Group, observableValue: Variable<Transform>, valueFunc: (Double) -> Transform, animationDuration: Double) {
		super.init(observableValue: observableValue, animationDuration: animationDuration)
		type = .AffineTransformation
		shape = animatedShape
		vFunc = valueFunc
	}
}