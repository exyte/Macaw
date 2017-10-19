//
//  TouchEvent.swift
//  Pods
//
//  Created by Victor Sukochev on 13/02/2017.
//
//

public struct TouchPoint {
    public let id: Int
    public let location: Point
}

public class TouchEvent: Event {

    public let points: [TouchPoint]

    public init(node: Node, points: [TouchPoint]) {
        self.points = points

        super.init(node: node)
    }
}
