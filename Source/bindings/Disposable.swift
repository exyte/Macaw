//
//  Disposable.swift
//  Pods
//
//  Created by Victor Sukochev on 29/11/2016.
//
//

import Foundation

open class Disposable {
    
    let handler: (()->())
    
    init (_ disposeHandler: @escaping (()->()) ) {
        handler = disposeHandler
    }
    
    open func dispose() {
        handler()
    }
}
