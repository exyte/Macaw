//
//  TouchEvent.swift
//  Pods
//
//  Created by Victor Sukochev on 13/02/2017.
//
//

public enum TouchEventState: Int {
    case began = 0
    case moved = 1
    case ended = 3
}

open class TouchEvent : Event, Hashable {
    
    open let location: Point
    open var state: TouchEventState
    
    init(node: Node, location: Point, state: TouchEventState) {
        self.location = location
        self.state = state
        
        super.init(node: node)
    }
    
    public var hashValue: Int {
        return (location.x + location.y).hashValue
    }
}

public func == (lhs: TouchEvent, rhs: TouchEvent) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
