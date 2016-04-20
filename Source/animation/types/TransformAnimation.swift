
public class TransformAnimation: Animation<Transform> {

	public required init(animatedShape: Shape, observableValue: ObservableValue<Transform>, startValue: Transform, finalValue: Transform, animationDuration: Double) {
		super.init(observableValue: observableValue, startValue: observableValue.get(), finalValue: finalValue, animationDuration: animationDuration)
		type = .AffineTransformation
		shape = animatedShape
	}
}