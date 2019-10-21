//
//  Event.swift
//  Pods
//
//  Created by Yuri Strot on 12/20/16.
//
//

import Foundation

open class Event {

    public weak var node: Node?

    var consumed = false

    init(node: Node) {
        self.node = node
    }

    public func consume() {
        consumed = true
    }
}
