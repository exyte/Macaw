//
//  MCAShapeLayerLineCap_macOS.swift
//  MacawOSX
//
//  Created by Anton Marunko on 27/09/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(OSX)
import AppKit

public struct MCAShapeLayerLineCap {
    static let butt = kCALineCapButt
    static let round = kCALineCapRound
    static let square = kCALineCapSquare

    static func mapToGraphics(model: LineCap) -> String {
        switch model {
        case .butt:
            return MCAShapeLayerLineCap.butt
        case .round:
            return MCAShapeLayerLineCap.round
        case .square:
            return MCAShapeLayerLineCap.square
        }
    }
}

#endif
