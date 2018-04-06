//
//  MView_macOS.swift
//  Macaw
//
//  Created by Daniil Manin on 8/17/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

#if os(OSX)
import AppKit

public enum MViewContentMode: Int {
    case scaleToFill = 0
    case scaleAspectFit = 1
    case scaleAspectFill = 2
    case redraw = 3
    case center = 4
    case top = 5
    case bottom = 6
    case left = 7
    case right = 8
    case topLeft = 9
    case topRight = 10
    case bottomLeft = 11
    case bottomRight = 12
}

open class MView: NSView, Touchable {
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.wantsLayer = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.wantsLayer = true
        setupMouse()
    }

    open override var isFlipped: Bool {
        return true
    }

    var mGestureRecognizers: [NSGestureRecognizer]? {
        return self.gestureRecognizers
    }

    open var backgroundColor: MColor? {
        get {
            return self.layer?.backgroundColor == nil ? nil : NSColor(cgColor: self.layer!.backgroundColor!)
        }

        set {
            self.layer?.backgroundColor = newValue == nil ? nil : newValue?.cgColor ?? MColor.black.cgColor
        }
    }

    var mLayer: CALayer? {
        return self.layer
    }

    var contentMode: MViewContentMode = .scaleToFill

    func removeGestureRecognizers() {
        self.gestureRecognizers.removeAll()
    }

    func didMoveToSuperview() {
        super.viewDidMoveToSuperview()
    }

    func setNeedsDisplay() {
        self.setNeedsDisplay(self.bounds)
    }

    func layoutSubviews() {
        super.resizeSubviews(withOldSize: self.bounds.size)
    }

    // MARK: - Touch pad
    open override func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)

        let touchPoints = event.touches(matching: .any, in: self).map { touch -> MTouchEvent in
            let location = touch.location(in: self)
            let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())

            return MTouchEvent(x: Double(location.x), y: Double(location.y), id: id)
        }

        mTouchesBegan(touchPoints)
    }

    open override func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)

        let touchPoints = event.touches(matching: .any, in: self).map { touch -> MTouchEvent in
            let location = touch.location(in: self)
            let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())

            return MTouchEvent(x: Double(location.x), y: Double(location.y), id: id)
        }

        mTouchesEnded(touchPoints)
    }

    open override func touchesMoved(with event: NSEvent) {
        super.touchesMoved(with: event)

        let touchPoints = event.touches(matching: .any, in: self).map { touch -> MTouchEvent in
            let location = touch.location(in: self)
            let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())

            return MTouchEvent(x: Double(location.x), y: Double(location.y), id: id)
        }

        mTouchesMoved(touchPoints)
    }

    open override func touchesCancelled(with event: NSEvent) {
        super.touchesCancelled(with: event)

        let touchPoints = event.touches(matching: .any, in: self).map { touch -> MTouchEvent in
            let location = touch.location(in: self)
            let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())

            return MTouchEvent(x: Double(location.x), y: Double(location.y), id: id)
        }

        mTouchesCancelled(touchPoints)
    }

    // MARK: - Mouse
    private func setupMouse() {
        subscribeForMouseDown()
        subscribeForMouseUp()
        subscribeForMouseDragged()
    }

    private func subscribeForMouseDown() {
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event -> NSEvent? in
            self?.handleInput(event: event) { touches in
                self?.mTouchesBegan(touches)
            }
            return event
        }
    }

    private func subscribeForMouseUp() {
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { [weak self] event -> NSEvent? in
            self?.handleInput(event: event) { touches in
                self?.mTouchesEnded(touches)
            }
            return event
        }
    }

    private func subscribeForMouseDragged() {
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseDragged) { [weak self] event -> NSEvent? in
            self?.handleInput(event: event) { touches in
                self?.mTouchesMoved(touches)
            }
            return event
        }
    }

    private func handleInput(event: NSEvent, handler: (_ touches: [MTouchEvent]) -> Void ) {
        let location = self.convert(event.locationInWindow, to: .none)
        let touchPoint = MTouchEvent(x: Double(location.x), y: Double(location.y), id: 0)

        handler([touchPoint])

        return
    }

    // MARK: - Touchable
    func mTouchesBegan(_ touches: [MTouchEvent]) {

    }

    func mTouchesMoved(_ touches: [MTouchEvent]) {

    }

    func mTouchesEnded(_ touches: [MTouchEvent]) {

    }

    func mTouchesCancelled(_ touches: [MTouchEvent]) {

    }
}
#endif
