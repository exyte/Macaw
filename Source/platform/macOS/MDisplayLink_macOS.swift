//
//  MDisplayLink_macOS.swift
//  Macaw
//
//  Created by Daniil Manin on 8/17/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

#if os(OSX)
  import AppKit

  public class MDisplayLink {
    private var timer: Timer?
    private var displayLink: CVDisplayLink?
    private weak var target: AnyObject?
    private var selector: Selector
    
    private var _timestamp: CFTimeInterval = 0.0
    public var timestamp: CFTimeInterval {
      return _timestamp
    }
    
    init(target: AnyObject, selector: Selector) {
      self.target = target
      self.selector = selector
      
      if CVDisplayLinkCreateWithActiveCGDisplays(&displayLink) == kCVReturnSuccess {
        
        CVDisplayLinkSetOutputCallback(displayLink!, { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, userData) -> CVReturn in
          
          let `self` = unsafeBitCast(userData, to: MDisplayLink.self)
          `self`._timestamp = CFAbsoluteTimeGetCurrent()
          `self`.target?.performSelector(onMainThread: `self`.selector, with: `self`, waitUntilDone: false)
          
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

#endif
