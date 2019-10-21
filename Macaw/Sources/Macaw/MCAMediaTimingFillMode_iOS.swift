//
//  MCAMediaTimingFillMode.swift
//  Macaw
//
//  Created by Anton Marunko on 27/09/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

public struct MCAMediaTimingFillMode {
    public static let forwards = CAMediaTimingFillMode.forwards
    public static let backwards = CAMediaTimingFillMode.backwards
    public static let both = CAMediaTimingFillMode.both
    public static let removed = CAMediaTimingFillMode.removed
}

#endif
