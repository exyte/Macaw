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
  public typealias MBezierPath = NSBezierPath
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
        self.layer?.backgroundColor = newValue == nil ? nil : newValue!.cgColor
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
  
  extension NSFont {
    var lineHeight: CGFloat {
      return self.boundingRectForFont.size.height
    }
    
    class var mSystemFontSize: CGFloat {
      return NSFont.systemFontSize()
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
    
    open func invalidate() {
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
  
  public struct MRectCorner: OptionSet {
    public let rawValue: UInt
    
    public static let none = MRectCorner(rawValue: 0)
    public static let topLeft = MRectCorner(rawValue: 1 << 0)
    public static let topRight = MRectCorner(rawValue: 1 << 1)
    public static let bottomLeft = MRectCorner(rawValue: 1 << 2)
    public static let bottomRight = MRectCorner(rawValue: 1 << 3)
    public static var allCorners: MRectCorner {
      return [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }
    
    public init(rawValue: UInt) {
      self.rawValue = rawValue
    }
  }
  
  extension MBezierPath {
    
    public var cgPath: CGPath {
      get { let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
          let type = self.element(at: i, associatedPoints: &points)
          switch type {
          case .moveToBezierPathElement:
            path.move(to: CGPoint(x: points[0].x, y: points[0].y))
          case .lineToBezierPathElement:
            path.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
          case .curveToBezierPathElement:
            path.addCurve(
              to: CGPoint(x: points[2].x, y: points[2].y),
              control1: CGPoint(x: points[0].x, y: points[0].y),
              control2: CGPoint(x: points[1].x, y: points[1].y))
          case .closePathBezierPathElement:
            path.closeSubpath()
          }
        }
        return path
      }
    }
    
    public convenience init(arcCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
      self.init()
      self.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
    }
    
    public convenience init(roundedRect rect: NSRect, byRoundingCorners corners: MRectCorner, cornerRadii: NSSize) {
      self.init()
      
      let kappa: CGFloat = 0.552228474
      let opKappa = 1 - kappa
      
      let topLeft = rect.origin
      let topRight = NSPoint(x: rect.maxX, y: rect.minY);
      let bottomRight = NSPoint(x: rect.maxX, y: rect.maxY);
      let bottomLeft = NSPoint(x: rect.minX, y: rect.maxY);
      
      if corners.contains(.topLeft) {
        move(to: CGPoint(x: topLeft.x + cornerRadii.width, y: topLeft.y))
        
      } else {
        move(to: topLeft)
      }
      
      if corners.contains(.topRight) {
        line(to: CGPoint(x: topRight.x - cornerRadii.width, y: topRight.y))
      
        curve(to: CGPoint(x: topRight.x, y: topRight.y + cornerRadii.height),
              controlPoint1: CGPoint(x: topRight.x - cornerRadii.width * opKappa, y: topRight.y),
              controlPoint2: CGPoint(x: topRight.x, y: topRight.y + cornerRadii.height * opKappa))
        
        
      } else {
        line(to: topRight)
      }
      
      if corners.contains(.bottomRight) {
        line(to: CGPoint(x: bottomRight.x, y: bottomRight.y - cornerRadii.height))
        
        curve(to: CGPoint(x: bottomRight.x - cornerRadii.width, y: bottomRight.y),
              controlPoint1: CGPoint(x: bottomRight.x, y: bottomRight.y - cornerRadii.height * opKappa),
              controlPoint2: CGPoint(x: bottomRight.x - cornerRadii.width * opKappa, y: bottomRight.y))
        
      } else {
        line(to: bottomRight)
      }
      
      if corners.contains(.bottomLeft) {
        line(to: CGPoint(x: bottomLeft.x + cornerRadii.width, y: bottomLeft.y))
        
        curve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - cornerRadii.height),
              controlPoint1: CGPoint(x: bottomLeft.x + cornerRadii.width * opKappa, y: bottomLeft.y),
              controlPoint2: CGPoint(x: bottomLeft.x, y: bottomLeft.y - cornerRadii.height * opKappa))
        
      } else {
        line(to: bottomLeft)
      }
      
      if corners.contains(.topLeft) {
        line(to: CGPoint(x: topLeft.x, y: topLeft.y + cornerRadii.height))
        
        curve(to: CGPoint(x: topLeft.x + cornerRadii.width, y: topLeft.y),
              controlPoint1: CGPoint(x: topLeft.x, y: topLeft.y + cornerRadii.height * opKappa),
              controlPoint2: CGPoint(x: topLeft.x + cornerRadii.width * opKappa, y: topLeft.y))
        
      } else {
        line(to: topLeft)
      }
      
      close()
    }
    
    func reversing() -> MBezierPath {
      return self.reversed
    }
    
    func addLine(to: NSPoint) {
      self.line(to: to)
    }
    
    func addCurve(to: NSPoint, controlPoint1: NSPoint, controlPoint2: NSPoint) {
      self.curve(to: to, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
    
    func addQuadCurveToPoint(endPoint: NSPoint, controlPoint: NSPoint) {
      let QP0 = self.currentPoint
      let CP3 = endPoint
      
      let CP1 = CGPoint(
        x: QP0.x + ((2.0 / 3.0) * (controlPoint.x - QP0.x)),
        y: QP0.y + ((2.0 / 3.0) * (controlPoint.y - QP0.y))
      )
      
      let CP2 = CGPoint(
        x: endPoint.x + (2.0 / 3.0) * (controlPoint.x - endPoint.x),
        y: endPoint.y + (2.0 / 3.0) * (controlPoint.y - endPoint.y)
      )
      
      self.addCurve(to: CP3, controlPoint1: CP1, controlPoint2: CP2)
    }
    
    func addArc(withCenter: NSPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
      let startAngleRadian = ((startAngle) * (180.0 / .pi))
      let endAngleRadian = ((endAngle) * (180.0 / .pi))
      self.appendArc(withCenter: withCenter, radius: radius, startAngle: startAngleRadian, endAngle: endAngleRadian, clockwise: !clockwise)
      
    }
    
    func addPath(path: NSBezierPath!) {
      self.append(path)
    }
  }

#endif

