//
//  AnimatableVariable.swift
//  Pods
//
//  Created by Yuri Strot on 8/24/16.
//
//

import RxSwift
import Foundation

open class AnimatableVariable<T: Interpolable> {
    
    internal var node: Node?
    
    private let _subject: BehaviorSubject<T>
    
    private var _lock = NSRecursiveLock()
    
    // state
    private var _value: T
    
    /**
     Gets or sets current value of variable.
     
     Whenever a new value is set, all the observers are notified of the change.
     
     Even if the newly set value is same as the old value, observers are still notified for change.
     */
    public var value: T {
        get {
            _lock.lock(); defer { _lock.unlock() }
            return _value
        }
        set(newValue) {
            _lock.lock()
            _value = newValue
            _lock.unlock()
            
            _subject.on(.next(newValue))
        }
    }
    
    /**
     Initializes variable with initial value.
     
     - parameter value: Initial variable value.
     */
    public init(_ value: T) {
        _value = value
        _subject = BehaviorSubject(value: value)
    }
    
    /**
     - returns: Canonical interface for push style sequence
     */
    public func asObservable() -> Observable<T> {
        return _subject
    }
    
    deinit {
        _subject.on(.completed)
    }
    
}
