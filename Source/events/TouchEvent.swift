//
//  TouchEvent.swift
//  Pods
//
//  Created by Victor Sukochev on 13/02/2017.
//
//

typealias NodeTouch = (Node, CGPoint)

public enum Relativity {
    case parent
    case scene
}

public struct TouchPoint {
    public let id: Int
    @available(*, deprecated) public let location: Point // absolute location
    private let absoluteLocation: Point
    private let relativeLocation: Point // location inside the node

    init(id: Int, location: Point, relativeLocation: Point) {
        self.id = id
        self.absoluteLocation = location
        self.relativeLocation = relativeLocation
        self.location = location
    }

    public func location(in relativity: Relativity = .parent) -> Point {
        switch relativity {
        case .parent:
            return relativeLocation
        case .scene:
            return absoluteLocation
        }
    }
}

public class TouchEvent: Event {

    public let points: [TouchPoint]

    public init(node: Node, points: [TouchPoint]) {
        self.points = points

        super.init(node: node)
    }
}
