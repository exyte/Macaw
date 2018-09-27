//
//  MCAMediaTimingFillMode_macOS.swift
//  MacawOSX
//
//  Created by Anton Marunko on 27/09/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(OSX)
import AppKit

public struct MCAMediaTimingFillMode {
    public static let forwards = kCAFillModeForwards
    public static let backwards = kCAFillModeBackwards
    public static let both = kCAFillModeBoth
    public static let removed = kCAFillModeRemoved
}

#endif
