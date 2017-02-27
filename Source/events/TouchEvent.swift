//
//  TouchEvent.swift
//  Pods
//
//  Created by Victor Sukochev on 13/02/2017.
//
//


public struct TouchPoint {
    let id: Int
    let location: Point
}

public class TouchEvent : Event {
    
    public  var point: TouchPoint
    
    public init(node: Node, point: TouchPoint) {
        self.point = point
        
        super.init(node: node)
    }
}
