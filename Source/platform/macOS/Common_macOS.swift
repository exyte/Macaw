//
//  Common_macOS.swift
//  Macaw
//
//  Created by Daniil Manin on 8/10/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

#if os(OSX)
    import Cocoa
    import Quartz

    public typealias MFont = NSFont
    public typealias MColor = NSColor
    public typealias MEvent = NSEvent
    public typealias MTouch = NSTouch
    public typealias MImage = NSImage
    public typealias MBezierPath = NSBezierPath
    public typealias MGestureRecognizer = NSGestureRecognizer
    public typealias MGestureRecognizerState = NSGestureRecognizer.State
    public typealias MGestureRecognizerDelegate = NSGestureRecognizerDelegate
    public typealias MTapGestureRecognizer = NSClickGestureRecognizer
    public typealias MPanGestureRecognizer = NSPanGestureRecognizer
    public typealias MPinchGestureRecognizer = NSMagnificationGestureRecognizer
    public typealias MRotationGestureRecognizer = NSRotationGestureRecognizer
    public typealias MScreen = NSScreen

    extension MGestureRecognizer {
        var cancelsTouchesInView: Bool {
            get {
                return false
            } set { }
        }
    }

    extension MTapGestureRecognizer {
        func mNumberOfTouches() -> Int {
            return 1
        }
    }

    extension MPanGestureRecognizer {
        func mNumberOfTouches() -> Int {
            return 1
        }

        func mLocationOfTouch(_ touch: Int, inView: NSView?) -> NSPoint {
            return super.location(in: inView)
        }
    }

    extension MRotationGestureRecognizer {
        var velocity: CGFloat {
            return 0.1
        }

        var mRotation: CGFloat {
            get {
                return -rotation
            }

            set {
                rotation = -newValue
            }
        }
    }

    extension MPinchGestureRecognizer {
        var mScale: CGFloat {
            get {
                return magnification + 1.0
            }

            set {
                magnification = newValue - 1.0
            }
        }

        func mLocationOfTouch(_ touch: Int, inView view: NSView?) -> NSPoint {
            return super.location(in: view)
        }
    }

    extension NSFont {
        var lineHeight: CGFloat {
            return self.boundingRectForFont.size.height
        }

        class var mSystemFontSize: CGFloat {
            return NSFont.systemFontSize
        }
    }

    extension NSScreen {
        var mScale: CGFloat {
            return self.backingScaleFactor
        }
    }

    extension NSImage {
        var cgImage: CGImage? {
            return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
        }
    }

    extension NSTouch {
        func location(in view: NSView) -> NSPoint {
            let n = self.normalizedPosition
            let b = view.bounds
            return NSPoint(x: b.origin.x + b.size.width * n.x, y: b.origin.y + b.size.height * n.y)
        }
    }

    extension NSString {
        @nonobjc
        func size(attributes attrs: [NSAttributedStringKey: Any]? = nil) -> NSSize {
            return size(withAttributes: attrs)
        }
    }

    func MMainScreen() -> MScreen? {
        return MScreen.main
    }

#endif
