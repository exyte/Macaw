//
//  Platform_macOS.swift
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
  public typealias MGestureRecognizer = NSGestureRecognizer
  public typealias MGestureRecognizerState = NSGestureRecognizerState
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
      } set {
        
      }
    }
  }
  
  
  extension MTapGestureRecognizer {
    func mNumberOfTouches() -> Int {
      return 1
    }
    
    var mNumberOfTapsRequired: Int {
      get {
        return self.numberOfClicksRequired
      }
      
      set {
        self.numberOfClicksRequired = newValue
      }
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
  
  open class MView: NSView {
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
        self.wantsLayer = true
        self.layer?.backgroundColor = newValue == nil ? nil : newValue!.cgColor
      }
    }
    
    var mLayer: CALayer? {
      return self.layer
    }
    
    func didMoveToSuperview() {
      super.viewDidMoveToSuperview()
    }
    
    func setNeedsDisplay() {
      self.setNeedsDisplay(self.bounds)
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
  
  extension NSFont {
    var lineHeight: CGFloat {
      return self.boundingRectForFont.size.height
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
    func locationInView(view: NSView) -> NSPoint {
      let n = self.normalizedPosition
      let b = view.bounds
      return NSPoint(x: b.origin.x + b.size.width * n.x, y: b.origin.y + b.size.height * n.y)
    }
  }
  
  extension NSString {
    @nonobjc
    func size(attributes attrs: [String : Any]? = nil) -> NSSize {
      return size(withAttributes: attrs)
    }
  }
  
  func MGraphicsGetCurrentContext() -> CGContext? {
    return NSGraphicsContext.current()?.cgContext
  }
  
  func MGraphicsPushContext(_ context: CGContext) {
    let cx = NSGraphicsContext(cgContext: context, flipped: true)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.setCurrent(cx)
  }
  
  func MGraphicsPopContext() {
    NSGraphicsContext.restoreGraphicsState()
  }
  
  func MImagePNGRepresentation(_ image: MImage) -> Data? {
    image.lockFocus()
    let rep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
    image.unlockFocus()
    return rep?.representation(using: NSPNGFileType, properties: [:])
  }
  
  func MImageJPEGRepresentation(_ image: MImage, _ quality: CGFloat = 0.9) -> Data? {
    image.lockFocus()
    let rep = NSBitmapImageRep(focusedViewRect: NSMakeRect(0, 0, image.size.width, image.size.height))
    image.unlockFocus()
    return rep?.representation(using: NSJPEGFileType, properties: [NSImageCompressionFactor: quality])
  }
  
  private var imageContextStack: [CGFloat] = []
  
  func MGraphicsBeginImageContextWithOptions(_ size: CGSize, _ opaque: Bool, _ scale: CGFloat) {
    var scale = scale
    
    if scale == 0.0 {
      scale = NSScreen.main()?.backingScaleFactor ?? 1.0
    }
    
    let width = Int(size.width * scale)
    let height = Int(size.height * scale)
    
    if width > 0 && height > 0 {
      imageContextStack.append(scale)
      
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      
      guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4*width, space: colorSpace, bitmapInfo: (opaque ?  CGImageAlphaInfo.noneSkipFirst.rawValue : CGImageAlphaInfo.premultipliedFirst.rawValue)) else {
        return
      }
      
      ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(height)))
      ctx.scaleBy(x: scale, y: scale)
      MGraphicsPushContext(ctx)
    }
  }
  
  func MGraphicsGetImageFromCurrentImageContext() -> MImage? {
    if !imageContextStack.isEmpty {
      guard let ctx = MGraphicsGetCurrentContext() else {
        return nil
      }
      
      let scale = imageContextStack.last!
      if let theCGImage = ctx.makeImage() {
        let size = CGSize(width: CGFloat(ctx.width) / scale, height: CGFloat(ctx.height) / scale)
        let image = NSImage(cgImage: theCGImage, size: size)
        return image
      }
    }
    
    return nil
  }
  
  func MGraphicsEndImageContext() {
    if imageContextStack.last != nil {
      imageContextStack.removeLast()
      MGraphicsPopContext()
    }
  }
  
  func MMainScreen() -> MScreen? {
    return MScreen.main()
  }
  
  public class MDisplayLink {
    private var timer: Timer?
    private var displayLink: CVDisplayLink?
    private var _timestamp: CFTimeInterval = 0.0
    
    private weak var _target: AnyObject?
    private var _selector: Selector
    
    public var timestamp: CFTimeInterval {
      return _timestamp
    }
    
    init(target: AnyObject, selector: Selector) {
      _target = target
      _selector = selector
      
      if CVDisplayLinkCreateWithActiveCGDisplays(&displayLink) == kCVReturnSuccess {
        
        CVDisplayLinkSetOutputCallback(displayLink!, { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, userData) -> CVReturn in
          
          let _self = unsafeBitCast(userData, to: MDisplayLink.self)
          
          _self._timestamp = CFAbsoluteTimeGetCurrent()
          _self._target?.performSelector(onMainThread: _self._selector, with: _self, waitUntilDone: false)
          
          return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())
      } else {
        timer = Timer(timeInterval: 1.0 / 60.0, target: target, selector: selector, userInfo: nil, repeats: true)
      }
    }
    
    deinit {
      stop()
    }
    
    open func add(to runloop: RunLoop, forMode mode: RunLoopMode) {
      if displayLink != nil {
        CVDisplayLinkStart(displayLink!)
        
      } else if timer != nil {
        runloop.add(timer!, forMode: mode)
      }
    }
    
    open func remove(from: RunLoop, forMode: RunLoopMode) {
      stop()
    }
    
    private func stop() {
      if displayLink != nil {
        CVDisplayLinkStop(displayLink!)
      }
      
      if timer != nil {
        timer?.invalidate()
      }
    }
  }
  
  
#endif

