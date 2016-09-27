//
//  https://github.com/safx/ObservableArray-RxSwift
//  ObservableArray.swift
//  ObservableArray
//
//  Created by Safx Developer on 2015/02/19.
//  Copyright (c) 2016 Safx Developers. All rights reserved.
//

import Foundation
import RxSwift

public struct ArrayChangeEvent {
    public let insertedIndices: [Int]
    public let deletedIndices: [Int]
    public let updatedIndices: [Int]
    
    fileprivate init(inserted: [Int] = [], deleted: [Int] = [], updated: [Int] = []) {
        assert(inserted.count + deleted.count + updated.count > 0)
        self.insertedIndices = inserted
        self.deletedIndices = deleted
        self.updatedIndices = updated
    }
}

public struct ObservableArray<Element>: ExpressibleByArrayLiteral {
    public typealias EventType = ArrayChangeEvent
    
    internal var eventSubject: PublishSubject<EventType>!
    internal var elementsSubject: PublishSubject<[Element]>!
    internal var elements: [Element]
    
    public init() {
        self.elements = []
    }
    
    public init(count:Int, repeatedValue: Element) {
        self.elements = Array(repeating: repeatedValue, count: count)
    }
    
    public init<S : Sequence>(_ s: S) where S.Iterator.Element == Element {
        self.elements = Array(s)
    }
    
    public init(arrayLiteral elements: Element...) {
        self.elements = elements
    }
    
    public init(array elements: [Element]) {
        self.elements = elements
    }
}

extension ObservableArray {
    public mutating func rx_elements() -> Observable<[Element]> {
        if elementsSubject == nil {
            self.elementsSubject = PublishSubject<[Element]>()
        }
        return elementsSubject
    }
    
    public mutating func rx_events() -> Observable<EventType> {
        if eventSubject == nil {
            self.eventSubject = PublishSubject<EventType>()
        }
        return eventSubject
    }
    
    fileprivate func arrayDidChange(_ event: EventType) {
        elementsSubject?.onNext(elements)
        eventSubject?.onNext(event)
    }
}

extension ObservableArray: Indexable {
    public var startIndex: Int {
        return elements.startIndex
    }
    
    public var endIndex: Int {
        return elements.endIndex
    }
    
    public func formIndex(after i: inout Int) {
        elements.formIndex(after: &i)
    }
    
    public func index(after i: Int) -> Int {
        elements.index(after: i)
    }
}

extension ObservableArray: RangeReplaceableCollection {
    public var capacity: Int {
        return elements.capacity
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }
    
    public mutating func append(_ newElement: Element) {
        elements.append(newElement)
        arrayDidChange(ArrayChangeEvent(inserted: [elements.count - 1]))
    }
    
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Iterator.Element == Element {
        let end = elements.count
        elements.append(contentsOf: newElements)
        guard end != elements.count else {
            return
        }
        arrayDidChange(ArrayChangeEvent(inserted: Array(end..<elements.count)))
    }
    
    public mutating func appendContentsOf<C : Collection>(_ newElements: C) where C.Iterator.Element == Element {
        guard !newElements.isEmpty else {
            return
        }
        let end = elements.count
        elements.append(contentsOf: newElements)
        arrayDidChange(ArrayChangeEvent(inserted: Array(end..<elements.count)))
    }
    
    public mutating func removeLast() -> Element {
        let e = elements.removeLast()
        arrayDidChange(ArrayChangeEvent(deleted: [elements.count]))
        return e
    }
    
    public mutating func insert(_ newElement: Element, at i: Int) {
        elements.insert(newElement, at: i)
        arrayDidChange(ArrayChangeEvent(inserted: [i]))
    }
    
    public mutating func remove(at index: Int) -> Element {
        let e = elements.remove(at: index)
        arrayDidChange(ArrayChangeEvent(deleted: [index]))
        return e
    }
    
    public mutating func removeAll(_ keepCapacity: Bool = false) {
        guard !elements.isEmpty else {
            return
        }
        let es = elements
        elements.removeAll(keepingCapacity: keepCapacity)
        arrayDidChange(ArrayChangeEvent(deleted: Array(0..<es.count)))
    }
    
    public mutating func insertContentsOf(_ newElements: [Element], atIndex i: Int) {
        guard !newElements.isEmpty else {
            return
        }
        elements.insert(contentsOf: newElements, at: i)
        arrayDidChange(ArrayChangeEvent(inserted: Array(i..<i + newElements.count)))
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newCollection: C) where C.Iterator.Element == Element {
        let oldCount = elements.count
        elements.replaceSubrange(subRange, with: newCollection)
        guard let first = subRange.first else {
            return
        }
        let newCount = elements.count
        let end = first + (newCount - oldCount) + subRange.count
        arrayDidChange(ArrayChangeEvent(inserted: Array(first..<end),
            deleted: Array(subRange)))
    }
    
    public mutating func popLast() -> Element? {
        let e = elements.popLast()
        if e != nil {
            arrayDidChange(ArrayChangeEvent(deleted: [elements.count]))
        }
        return e
    }
}

extension ObservableArray: CustomDebugStringConvertible {
    public var description: String {
        return elements.description
    }
}

extension ObservableArray: CustomStringConvertible {
    public var debugDescription: String {
        return elements.debugDescription
    }
}

extension ObservableArray: Collection {
    public subscript(index: Int) -> Element {
        get {
            return elements[index]
        }
        set {
            elements[index] = newValue
            if index == elements.count {
                arrayDidChange(ArrayChangeEvent(inserted: [index]))
            } else {
                arrayDidChange(ArrayChangeEvent(updated: [index]))
            }
        }
    }
    
    public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        get {
            return elements[bounds]
        }
        set {
            elements[bounds] = newValue
            guard let first = bounds.first else {
                return
            }
            arrayDidChange(ArrayChangeEvent(inserted: Array(first..<first + newValue.count),
                deleted: Array(bounds)))
        }
    }
}
