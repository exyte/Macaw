//
//  Common_iOS.swift
//  Macaw
//
//  Created by Daniil Manin on 8/10/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
    import UIKit

    public typealias MRectCorner = UIRectCorner
    public typealias MFont = UIFont
    public typealias MColor = UIColor
    public typealias MEvent = UIEvent
    public typealias MTouch = UITouch
    public typealias MImage = UIImage
    public typealias MBezierPath = UIBezierPath
    public typealias MGestureRecognizer = UIGestureRecognizer
    public typealias MGestureRecognizerState = UIGestureRecognizerState
    public typealias MGestureRecognizerDelegate = UIGestureRecognizerDelegate
    public typealias MTapGestureRecognizer = UITapGestureRecognizer
    public typealias MLongPressGestureRecognizer = UILongPressGestureRecognizer
    public typealias MPanGestureRecognizer = UIPanGestureRecognizer

    #if os(iOS)
    public typealias MPinchGestureRecognizer = UIPinchGestureRecognizer
    public typealias MRotationGestureRecognizer = UIRotationGestureRecognizer
    #endif

    public typealias MScreen = UIScreen
    public typealias MViewContentMode = UIViewContentMode

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

    #if os(iOS)
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
    #endif

    extension MFont {
        class var mSystemFontSize: CGFloat {
            #if os(iOS)
                return UIFont.systemFontSize
            #elseif os(tvOS)
                return 12.0
            #endif
        }
    }

    extension UIScreen {
        var mScale: CGFloat {
            return self.scale
        }
    }

#endif
