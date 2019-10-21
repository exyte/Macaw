//
//  DescriptionExtensions.swift
//  Macaw
//
//  Created by Anton Marunko on 21/06/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

extension Rect: CustomStringConvertible {
    public var description: String {
        return "x: \(String(format: "%f", x)), y: \(String(format: "%f", y)), w: \(String(format: "%f", w)), h: \(String(format: "%f", h))"
    }
}
