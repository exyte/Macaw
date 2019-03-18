//
//  MCAMediaTimingFunctionName_macOS.swift
//  MacawOSX
//
//  Created by Anton Marunko on 27/09/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(OSX)
import AppKit

public struct MCAMediaTimingFunctionName {
    static let linear = CAMediaTimingFunctionName.default
    static let easeIn = CAMediaTimingFunctionName.easeIn
    static let easeOut = CAMediaTimingFunctionName.easeOut
    static let easeInEaseOut = CAMediaTimingFunctionName.easeInEaseOut
    static let `default` = CAMediaTimingFunctionName.default
}

#endif
