//
//  Platform_iOS.swift
//  Macaw
//
//  Created by Daniil Manin on 8/10/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
  import UIKit
  
  public typealias MFont = UIFont
  public typealias MColor = UIColor
  public typealias MEvent = UIEvent
  public typealias MTouch = UITouch
  public typealias MImage = UIImage
  public typealias MGestureRecognizer = UIGestureRecognizer
  public typealias MGestureRecognizerState = UIGestureRecognizerState
  public typealias MGestureRecognizerDelegate = UIGestureRecognizerDelegate
  public typealias MTapGestureRecognizer = UITapGestureRecognizer
  public typealias MPanGestureRecognizer = UIPanGestureRecognizer
  public typealias MPinchGestureRecognizer = UIPinchGestureRecognizer
  public typealias MRotationGestureRecognizer = UIRotationGestureRecognizer
  public typealias MScreen = UIScreen
  public typealias MDisplayLink = CADisplayLink
  
  extension MTapGestureRecognizer {
    func mNumberOfTouches() -> Int {
      return numberOfTouches
    }
    
    var mNumberOfTapsRequired: Int {
      get {
        return self.numberOfTapsRequired
      }
      
      set {
        self.numberOfTapsRequired = newValue
      }
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
  
  open class MView: UIView {
    
    var mLayer: CALayer? {
      return self.layer
    }
    
    var mGestureRecognizers: [MGestureRecognizer]? {
      return self.gestureRecognizers
    }
    
    open override func touchesBegan(_ touches: Set<MTouch>, with event: MEvent?) {
      self.mTouchesBegan(touches, withEvent: event)
    }
    
    open override func touchesMoved(_ touches: Set<MTouch>, with event: MEvent?) {
      self.mTouchesMoved(touches, withEvent: event)
    }
    
    open override func touchesEnded(_ touches: Set<MTouch>, with event: MEvent?) {
      self.mTouchesEnded(touches, withEvent: event)
    }
    
    open override func touchesCancelled(_ touches: Set<MTouch>, with event: MEvent?) {
      self.mTouchesCancelled(touches, withEvent: event)
    }
    
    open func mTouchesBegan(_ touches: Set<MTouch>, with event: MEvent?) {
      super.touchesBegan(touches, with: event)
    }
    
    open func mTouchesMoved(_ touches: Set<MTouch>, with event: MEvent?) {
      super.touchesMoved(touches, with: event)
    }
    
    open func mTouchesEnded(_ touches: Set<MTouch>, with event: MEvent?) {
      super.touchesEnded(touches, with: event)
    }
    
    open func mTouchesCancelled(_ touches: Set<MTouch>, with event: MEvent?) {
      super.touchesCancelled(touches, with: event)
    }
  }
  
  extension UIScreen {
    var mScale: CGFloat {
      return self.scale
    }
  }
  
  func MGraphicsGetCurrentContext() -> CGContext? {
    return UIGraphicsGetCurrentContext()
  }
  
  func MGraphicsGetImageFromCurrentImageContext() -> MImage! {
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
  func MGraphicsPushContext(_ context: CGContext) {
    UIGraphicsPushContext(context)
  }
  
  func MGraphicsPopContext() {
    UIGraphicsPopContext()
  }
  
  func MGraphicsEndImageContext() {
    UIGraphicsEndImageContext()
  }
  
  func MImagePNGRepresentation(_ image: MImage) -> Data? {
    return UIImagePNGRepresentation(image)
  }
  
  func MImageJPEGRepresentation(_ image: MImage, _ quality: CGFloat = 0.8) -> Data? {
    return UIImageJPEGRepresentation(image, quality)
  }
  
  func MMainScreen() -> MScreen? {
    return MScreen.main
  }
  
  func MGraphicsBeginImageContextWithOptions(_ size: CGSize, _ opaque: Bool, _ scale: CGFloat) {
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
  }
 
#endif
  
