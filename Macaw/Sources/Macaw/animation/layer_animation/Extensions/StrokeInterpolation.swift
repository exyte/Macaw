//
//  StrokeInterpolation.swift
//  Pods
//
//  Created by Victor Sukochev on 14/02/2017.
//
//

public protocol StrokeInterpolation: Interpolable {

}

extension Stroke: StrokeInterpolation {
    public func interpolate(_ endValue: Stroke, progress: Double) -> Self {
        return self
    }
}
