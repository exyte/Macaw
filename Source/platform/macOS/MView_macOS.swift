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
    case scaleToFill
    case scaleAspectFit
    case scaleAspectFill
    case redraw
    case center
    case top
    case bottom
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
  }
  
  open class MView: NSView {
    public override init(frame frameRect: NSRect) {
      super.init(frame: frameRect)
      
      self.wantsLayer = true
    }
    
    public required init?(coder: NSCoder) {
      super.init(coder: coder)
      
      self.wantsLayer = true
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
    
    open override func touchesBegan(with event: NSEvent) {
      self.mTouchesBegan(event.touches(matching: .any, in: self), with: event)
    }
    
    open override func touchesEnded(with event: NSEvent) {
      self.mTouchesEnded(event.touches(matching: .any, in: self), with: event)
    }
    
    open override func touchesMoved(with event: NSEvent) {
      self.mTouchesMoved(event.touches(matching: .any, in: self), with: event)
    }
    
    open override func touchesCancelled(with event: NSEvent) {
      self.mTouchesCancelled(event.touches(matching: .any, in: self), with: event)
    }
    
    open func mTouchesBegan(_ touches: Set<MTouch>, with event: MEvent?) {
      super.touchesBegan(with: event!)
    }
    
    open func mTouchesMoved(_ touches: Set<MTouch>, with event: MEvent?) {
      super.touchesMoved(with: event!)
    }
    
    open func mTouchesEnded(_ touches: Set<MTouch>, with event: MEvent?) {
      super.touchesEnded(with: event!)
    }
    
    open func mTouchesCancelled(_ touches: Set<MTouch>, with event: MEvent?) {
      super.touchesCancelled(with: event!)
    }
  }
#endif
