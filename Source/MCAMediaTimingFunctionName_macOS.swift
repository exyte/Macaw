//
//  MCAMediaTimingFunctionName_macOS.swift
//  MacawOSX
//
//  Created by Anton Marunko on 27/09/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

import Foundation

#if os(OSX)
import AppKit

public struct MCAMediaTimingFunctionName {
    static let linear = kCAMediaTimingFunctionDefault
    static let easeIn = kCAMediaTimingFunctionEaseIn
    static let easeOut = kCAMediaTimingFunctionEaseOut
    static let easeInEaseOut = kCAMediaTimingFunctionEaseInEaseOut
    static let `default` = kCAMediaTimingFunctionDefault
}

#endif
