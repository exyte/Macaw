//
//  AnimatableVariable.swift
//  Pods
//
//  Created by Yuri Strot on 8/24/16.
//
//

import Foundation


open class AnimatableVariable<T: Interpolable>: Variable<T> {
    internal var node: Node?
}
