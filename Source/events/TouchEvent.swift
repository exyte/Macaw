//
//  TouchEvent.swift
//  Pods
//
//  Created by Victor Sukochev on 13/02/2017.
//
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

public enum Relativity {
    case parent
    case scene
}

class NodePath {
    let node: Node
    let location: CGPoint
    let parent: NodePath?

    init(node: Node, location: CGPoint, parent: NodePath? = nil) {
        self.node = node
        self.location = location
        self.parent = parent
    }
}

public struct TouchPoint {
    public let id: Int
    @available(*, deprecated) public var location: Point // absolute location
    { return absoluteLocation }

    private let absoluteLocation: Point
    private let relativeLocation: Point // location inside the node

    init(id: Int, location: Point, relativeLocation: Point) {
        self.id = id
        self.absoluteLocation = location
        self.relativeLocation = relativeLocation
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
