//
//  MCAShapeLayerLineCap_iOS.swift
//  Macaw
//
//  Created by Anton Marunko on 27/09/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

public struct MCAShapeLayerLineCap {
    static let butt = CAShapeLayerLineCap.butt
    static let round = CAShapeLayerLineCap.round
    static let square = CAShapeLayerLineCap.square

    static func mapToGraphics(model: LineCap) -> CAShapeLayerLineCap {
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
