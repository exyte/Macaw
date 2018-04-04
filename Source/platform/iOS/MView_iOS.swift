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

        let touchPoints = touches.map { touch -> MTouchEvent in
            let location = touch.location(in: self)
            let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())

            return MTouchEvent(x: Double(location.x), y: Double(location.y), id: id)
        }

        mTouchesBegan(touchPoints)
    }

    open override func touchesMoved(_ touches: Set<MTouch>, with event: MEvent?) {
        super.touchesMoved(touches, with: event)

        let touchPoints = touches.map { touch -> MTouchEvent in
            let location = touch.location(in: self)
            let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())

            return MTouchEvent(x: Double(location.x), y: Double(location.y), id: id)
        }

        self.mTouchesMoved(touchPoints)
    }

    open override func touchesEnded(_ touches: Set<MTouch>, with event: MEvent?) {
        super.touchesEnded(touches, with: event)

        let touchPoints = touches.map { touch -> MTouchEvent in
            let location = touch.location(in: self)
            let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())

            return MTouchEvent(x: Double(location.x), y: Double(location.y), id: id)
        }

        mTouchesEnded(touchPoints)
    }

    override open func touchesCancelled(_ touches: Set<MTouch>, with event: MEvent?) {
        super.touchesCancelled(touches, with: event)

        let touchPoints = touches.map { touch -> MTouchEvent in
            let location = touch.location(in: self)
            let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())

            return MTouchEvent(x: Double(location.x), y: Double(location.y), id: id)
        }

        mTouchesCancelled(touchPoints)
    }

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
