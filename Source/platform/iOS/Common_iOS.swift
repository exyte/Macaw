//
//  Common_iOS.swift
//  Macaw
//
//  Created by Daniil Manin on 8/10/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

public typealias MRectCorner = UIRectCorner
public typealias MFont = UIFont
public typealias MFontDescriptor = UIFontDescriptor
public typealias MColor = UIColor
public typealias MEvent = UIEvent
public typealias MTouch = UITouch
public typealias MImage = UIImage
public typealias MBezierPath = UIBezierPath
public typealias MGestureRecognizer = UIGestureRecognizer
public typealias MGestureRecognizerState = UIGestureRecognizer.State
public typealias MGestureRecognizerDelegate = UIGestureRecognizerDelegate
public typealias MTapGestureRecognizer = UITapGestureRecognizer
public typealias MLongPressGestureRecognizer = UILongPressGestureRecognizer
public typealias MPanGestureRecognizer = UIPanGestureRecognizer
public typealias MPinchGestureRecognizer = UIPinchGestureRecognizer
public typealias MRotationGestureRecognizer = UIRotationGestureRecognizer
public typealias MScreen = UIScreen
public typealias MViewContentMode = UIView.ContentMode

func MDefaultRunLoopMode() -> RunLoop.Mode {
    return RunLoop.Mode.default
}

extension MTapGestureRecognizer {
    func mNumberOfTouches() -> Int {
        return numberOfTouches
    }
}

extension MPanGestureRecognizer {
    func mNumberOfTouches() -> Int {
        return numberOfTouches
    }

    func mLocationOfTouch(_ touch: Int, inView: UIView?) -> CGPoint {
        return super.location(ofTouch: touch, in: inView)
    }
}

extension MRotationGestureRecognizer {
    final var mRotation: CGFloat {
        get {
            return rotation
        }

        set {
            rotation = newValue
        }
    }
}

extension MPinchGestureRecognizer {
    var mScale: CGFloat {
        get {
            return scale
        }

        set {
            scale = newValue
        }
    }

    func mLocationOfTouch(_ touch: Int, inView: UIView?) -> CGPoint {
        return super.location(ofTouch: touch, in: inView)
    }
}

extension MFont {
    class var mSystemFontSize: CGFloat {
        return UIFont.systemFontSize
    }

    class var mFamilyNames: [String] {
        return UIFont.familyNames
    }

    class func mFontNames(forFamily: String) -> [String] {
        return UIFont.fontNames(forFamilyName: forFamily)
    }
}

extension UIScreen {
    var mScale: CGFloat {
        return self.scale
    }
}

#endif
