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

public typealias MWindow = NSWindow
public typealias MFont = NSFont
public typealias MFontDescriptor = NSFontDescriptor
public typealias MColor = NSColor
public typealias MEvent = NSEvent
public typealias MTouch = NSTouch
public typealias MImage = NSImage
public typealias MBezierPath = NSBezierPath
public typealias MGestureRecognizer = NSGestureRecognizer
public typealias MGestureRecognizerState = NSGestureRecognizer.State
public typealias MGestureRecognizerDelegate = NSGestureRecognizerDelegate
public typealias MTapGestureRecognizer = NSClickGestureRecognizer
public typealias MLongPressGestureRecognizer = NSPressGestureRecognizer
public typealias MPanGestureRecognizer = NSPanGestureRecognizer
public typealias MPinchGestureRecognizer = NSMagnificationGestureRecognizer
public typealias MRotationGestureRecognizer = NSRotationGestureRecognizer
public typealias MScreen = NSScreen

func MDefaultRunLoopMode() -> RunLoop.Mode {
    RunLoop.Mode.default
}

extension MGestureRecognizer {
    var cancelsTouchesInView: Bool {
        get {
            false
        } set { }
    }
}

extension MTapGestureRecognizer {
    func mNumberOfTouches() -> Int {
        1
    }
}

extension MPanGestureRecognizer {
    func mNumberOfTouches() -> Int {
        1
    }

    func mLocationOfTouch(_ touch: Int, inView: NSView?) -> NSPoint {
        super.location(in: inView)
    }
}

extension MRotationGestureRecognizer {
    var velocity: CGFloat {
        0.1
    }

    var mRotation: CGFloat {
        get {
            -rotation
        }

        set {
            rotation = -newValue
        }
    }
}

extension MPinchGestureRecognizer {
    var mScale: CGFloat {
        get {
            magnification + 1.0
        }

        set {
            magnification = newValue - 1.0
        }
    }

    func mLocationOfTouch(_ touch: Int, inView view: NSView?) -> NSPoint {
        super.location(in: view)
    }
}

extension NSFont {
    var lineHeight: CGFloat {
        self.boundingRectForFont.size.height
    }

    class var mSystemFontSize: CGFloat {
        NSFont.systemFontSize
    }

    class var mFamilyNames: [String] {
        NSFontManager.shared.availableFontFamilies
    }

    class func mFontNames(forFamily: String) -> [String] {
        var result = [String]()
        if let members = NSFontManager.shared.availableMembers(ofFontFamily: forFamily) {
            for member in members {
                result.append(member[0] as! String)
            }
        }
        return result
    }

}

extension NSScreen {
    var mScale: CGFloat {
        self.backingScaleFactor
    }
}

extension NSImage {
    var cgImage: CGImage? {
        self.cgImage(forProposedRect: nil, context: nil, hints: nil)
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
    func size(attributes attrs: [NSAttributedString.Key: Any]? = nil) -> NSSize {
        size(withAttributes: attrs)
    }
}

func MMainScreen() -> MScreen? {
    MScreen.main
}

extension MBezierPath {
    func apply(_ transform: CGAffineTransform) {
        let affineTransform = AffineTransform(
            m11: transform.a,
            m12: transform.b,
            m21: transform.c,
            m22: transform.d,
            tX: transform.tx,
            tY: transform.ty
        )

        self.transform(using: affineTransform)
    }
}

extension CGContext {
    private struct CGContextScale {
        static var _scale: CGFloat = 0.0
    }

    var scale: CGFloat {
        get {
            CGContextScale._scale
        }

        set(newValue) {
            CGContextScale._scale = newValue
        }
    }
}

extension NSWindow {

    func addSubview(_ subview: NSView) {
        contentView?.addSubview(subview)
    }
}

extension NSBezierPath {
    var mUsesEvenOddFillRule: Bool {
        self.windingRule == .evenOdd
    }
}

#endif
