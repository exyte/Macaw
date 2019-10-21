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

open class MView: UIView, Touchable {
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
        super.touchesBegan(touches, with: event)
        mTouchesBegan(touches, with: event)
    }

    open override func touchesMoved(_ touches: Set<MTouch>, with event: MEvent?) {
        super.touchesMoved(touches, with: event)
        mTouchesMoved(touches, with: event)
    }

    open override func touchesEnded(_ touches: Set<MTouch>, with event: MEvent?) {
        super.touchesEnded(touches, with: event)
        mTouchesEnded(touches, with: event)
    }

    override open func touchesCancelled(_ touches: Set<MTouch>, with event: MEvent?) {
        super.touchesCancelled(touches, with: event)
        mTouchesCancelled(touches, with: event)
    }

    func mTouchesBegan(_ touches: Set<MTouch>, with event: MEvent?) {
    }

    func mTouchesMoved(_ touches: Set<MTouch>, with event: MEvent?) {
    }

    func mTouchesEnded(_ touches: Set<MTouch>, with event: MEvent?) {
    }

    func mTouchesCancelled(_ touches: Set<MTouch>, with event: MEvent?) {
    }
}

#endif
