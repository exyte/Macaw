import Foundation

// swiftlint:disable trailing_closure
public func >> (a: Double, b: Double) -> OpacityAnimationDescription {
    OpacityAnimationDescription(valueFunc: { t in
        a.interpolate(b, progress: t)
    })
}

public func >> (a: Transform, b: Transform) -> TransformAnimationDescription {
    TransformAnimationDescription(valueFunc: { t in
        a.interpolate(b, progress: t)
    })
}

public func >> (a: Locus, b: Locus) -> MorphingAnimationDescription {
    MorphingAnimationDescription(valueFunc: { t in
        // return a.interpolate(b, progress: t)
        if t == 0.0 {
            return a
        }

        return b
    })
}
// swiftlint:enable trailing_closure
