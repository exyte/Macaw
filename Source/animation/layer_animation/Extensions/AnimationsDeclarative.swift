
import RxSwift

public extension Node {

	func animate(desc: AnimationDescription<Double>) {
		let _ = OpacityAnimation(animatedNode: self, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
	}

	func animate(desc: AnimationDescription<Transform>) {
		let _ = TransformAnimation(animatedNode: self, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
	}

	func animation(desc: AnimationDescription<Double>) -> OpacityAnimation {
		return OpacityAnimation(animatedNode: self, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
	}

	func animation(desc: AnimationDescription<Transform>) -> TransformAnimation {
		return TransformAnimation(animatedNode: self, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
	}

}

/*

 public extension Variable where Element: Double {
 func animate(desc: AnimationDescription<Double>) {
 let _ = OpacityAnimation(animatedNode: self, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
 }

 func animation(desc: AnimationDescription<Double>) -> Animatable {
 return OpacityAnimation(animatedNode: self, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
 }

 }

 public extension Variable where Element: Transform {
 func animate(desc: AnimationDescription<Transform>) {
 let _ = TransformAnimation(animatedNode: self, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
 }

 func animation(desc: AnimationDescription<Transform>) -> Animatable {
 return TransformAnimation(animatedNode: self, valueFunc: desc.valueFunc, animationDuration: desc.duration, autostart: true)
 }

 }
 */
