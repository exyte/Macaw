//
//  FillInterpolation.swift
//  Pods
//
//  Created by Victor Sukochev on 14/02/2017.
//
//

public protocol FillInterpolation: Interpolable {

}

extension Fill: FillInterpolation {
    public func interpolate(_ endValue: Fill, progress: Double) -> Self {
        return self
    }
}
