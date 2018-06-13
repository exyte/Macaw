//
//  NodeContextExtension.swift
//  Macaw
//
//  Created by Anton Marunko on 09/06/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

extension Node {
    internal func createContext() -> CGContext? {

        let smallSize = CGSize(width: 1.0, height: 1.0)

        MGraphicsBeginImageContextWithOptions(smallSize, false, 0.0)
        return MGraphicsGetCurrentContext()
    }

    internal func endContext() {
        MGraphicsEndImageContext()
    }
}
