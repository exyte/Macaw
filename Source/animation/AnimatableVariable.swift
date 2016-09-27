//
//  AnimatableVariable.swift
//  Pods
//
//  Created by Yuri Strot on 8/24/16.
//
//

import RxSwift

open class AnimatableVariable<T: Interpolable> : Variable<T> {

    internal var node: Node?

    public override init(_ value: T) {
        super.init(value)
    }

}
