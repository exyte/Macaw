//
//  Variable.swift
//  Pods
//
//  Created by Victor Sukochev on 29/11/2016.
//
//

import Foundation

class  ChangeHandler<T>: Equatable {
    let handle: ((T) -> Void)

    init(_ f: @escaping ((T) -> Void) ) {
        handle = f
    }

    static func == (lhs: ChangeHandler<T>, rhs: ChangeHandler<T>) -> Bool {
        return lhs === rhs
    }
}

open class Variable<T> {
    var handlers = [ChangeHandler<T>]()

    open var value: T {
        didSet {
            handlers.forEach { handler in handler.handle(value) }
        }
    }

    init(_ v: T) {
        value = v
    }

    @discardableResult open func onChange(_ f: @escaping ((T) -> Void)) -> Disposable {
        let handler = ChangeHandler<T>(f)
        handlers.append(handler)
        return Disposable { [weak self, unowned handler] in
            guard let index = self?.handlers.index(of: handler) else {
                return
            }

            self?.handlers.remove(at: index)
        }
    }
}
