
import Foundation

infix operator ~ {
	associativity right
	precedence 155
}

public func >> (a: Double, b: Double) -> OpacityAnimationDescription {
	return OpacityAnimationDescription(valueFunc: { t in
		return a.interpolate(b, progress: t)
	})
}

public func >> (a: Transform, b: Transform) -> TransformAnimationDescription {
	return TransformAnimationDescription(valueFunc: { t in
		return a.interpolate(b, progress: t)
	})
}
