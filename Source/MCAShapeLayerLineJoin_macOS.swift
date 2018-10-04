//
//  MCAShapeLayerLineJoin_macOS.swift
//  MacawOSX
//
//  Created by Anton Marunko on 27/09/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(OSX)
import AppKit

public struct MCAShapeLayerLineJoin {
    public static let miter = CAShapeLayerLineJoin.miter
    public static let round = CAShapeLayerLineJoin.round
    public static let bevel = CAShapeLayerLineJoin.bevel

    static func mapToGraphics(model: LineJoin) -> CAShapeLayerLineJoin {
        switch model {
        case .miter:
            return MCAShapeLayerLineJoin.miter
        case .round:
            return MCAShapeLayerLineJoin.round
        case .bevel:
            return MCAShapeLayerLineJoin.bevel
        }
    }
}

#endif
