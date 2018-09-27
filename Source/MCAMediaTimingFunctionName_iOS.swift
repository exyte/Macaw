//
//  MCAMediaTimingFunctionName_iOS.swift
//  Macaw
//
//  Created by Anton Marunko on 27/09/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

public struct MCAMediaTimingFunctionName {
    static let linear = CAMediaTimingFunctionName.linear
    static let easeIn = CAMediaTimingFunctionName.easeIn
    static let easeOut = CAMediaTimingFunctionName.easeOut
    static let easeInEaseOut = CAMediaTimingFunctionName.easeInEaseOut
    static let `default` = CAMediaTimingFunctionName.default
}

#endif
