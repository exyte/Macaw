//
//  Disposable.swift
//  Pods
//
//  Created by Victor Sukochev on 29/11/2016.
//
//

import Foundation

open class Disposable {

    let handler: (() -> Void)

    init (_ disposeHandler: @escaping (() -> Void) ) {
        handler = disposeHandler
    }

    open func dispose() {
        handler()
    }
}
