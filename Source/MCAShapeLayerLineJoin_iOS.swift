//
//  MCAShapeLayerLineJoin_iOS.swift
//  MacawOSX
//
//  Created by Anton Marunko on 27/09/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

public struct MCAShapeLayerLineJoin {
    static let miter = CAShapeLayerLineJoin.miter
    static let round = CAShapeLayerLineJoin.round
    static let bevel = CAShapeLayerLineJoin.bevel

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
