//
//  ShapeInterpolation.swift
//  Pods
//
//  Created by Victor Sukochev on 03/02/2017.
//
//

public protocol ShapeInterpolation: Interpolable {

}

extension Shape: ShapeInterpolation {
    public func interpolate(_ endValue: Shape, progress: Double) -> Self {
        return self
    }
}
