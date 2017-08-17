//
//  MView_iOS.swift
//  Macaw
//
//  Created by Daniil Manin on 8/17/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
  import UIKit

  open class MView: UIView {
    var mLayer: CALayer? {
      return self.layer
    }
    
    var mGestureRecognizers: [MGestureRecognizer]? {
      return self.gestureRecognizers
    }
    
    func removeGestureRecognizers() {
      self.gestureRecognizers?.removeAll()
    }
    
    open override func touchesBegan(_ touches: Set<MTouch>, with event: MEvent?) {
      self.mTouchesBegan(touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<MTouch>, with event: MEvent?) {
      self.mTouchesMoved(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<MTouch>, with event: MEvent?) {
      self.mTouchesEnded(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<MTouch>, with event: MEvent?) {
      self.mTouchesCancelled(touches, with: event)
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

#endif

