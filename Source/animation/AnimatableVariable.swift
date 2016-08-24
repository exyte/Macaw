//
//  AnimatableVariable.swift
//  Pods
//
//  Created by Yuri Strot on 8/24/16.
//
//

import RxSwift

public class AnimatableVariable<T: Interpolable> : Variable<T> {

    public override init(_ value: T) {
        super.init(value)
    }

}
