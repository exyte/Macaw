//
//  MacawZoom.swift
//  Macaw
//
//  Created by Yuri Strot on 4/5/19.
//  Copyright © 2019 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

open class MacawZoom {

    private var view: MView!
    private var onChange: ((Transform) -> Void)!
    private var touches = [TouchData]()
    private var zoomData = ZoomData()

    private var trackMove = false
    private var trackScale = false
    private var trackRotate = false

    open func enable(move: Bool = true, scale: Bool = true, rotate: Bool = false) {
        trackMove = move
        trackScale = scale
        trackRotate = rotate
        if scale || rotate {
            #if os(iOS)
            view.isMultipleTouchEnabled = true
            #endif
        }
    }

    open func disable() {
        trackMove = false
        trackScale = false
        trackRotate = false
    }

    open func set(offset: Size? = nil, scale: Double? = nil, angle: Double? = nil) {
        let o = offset ?? zoomData.offset
        let s = scale ?? zoomData.scale
        let a = angle ?? zoomData.angle
        zoomData = ZoomData(offset: o, scale: s, angle: a)
        onChange(zoomData.transform())
    }

    func initialize(view: MView, onChange: @escaping ((Transform) -> Void)) {
        self.view = view
        self.onChange = onChange
    }

    func touchesBegan(_ touches: Set<MTouch>) {
        zoomData = getNewZoom()
        self.touches = self.touches.map { TouchData(touch: $0.touch, in: view) }
        self.touches.append(contentsOf: touches.map { TouchData(touch: $0, in: view) })
    }

    func touchesMoved(_ touches: Set<MTouch>) {
        let zoom = cleanTouches() ?? getNewZoom()
        onChange(zoom.transform())
    }

    func touchesEnded(_ touches: Set<MTouch>) {
        cleanTouches()
    }

    @discardableResult private func cleanTouches() -> ZoomData? {
        let newTouches = touches.filter { $0.touch.phase.rawValue < MTouch.Phase.ended.rawValue }
        if newTouches.count != touches.count {
            zoomData = getNewZoom()
            touches = newTouches.map { TouchData(touch: $0.touch, in: view) }
            return zoomData
        }
        return nil
    }

    private func getNewZoom() -> ZoomData {
        if touches.isEmpty || (touches.count == 1 && !trackMove) {
            return zoomData
        }
        let s1 = touches[0].point
        let e1 = touches[0].current(in: view)
        if touches.count == 1 {
            return zoomData.move(delta: e1 - s1)
        }
        let s2 = touches[1].point
        let e2 = touches[1].current(in: view)
        let scale = trackScale ? e1.distance(to: e2) / s1.distance(to: s2) : 1
        let a = trackRotate ? (e1 - e2).angle() - (s1 - s2).angle() : 0
        var offset = Size.zero
        if trackMove {
            let sina = sin(a)
            let cosa = cos(a)
            let w = e1.x - scale * (s1.x * cosa - s1.y * sina)
            let h = e1.y - scale * (s1.x * sina + s1.y * cosa)
            offset = Size(w: w, h: h)
        }
        return ZoomData(offset: offset, scale: scale, angle: a).combine(with: zoomData)
    }

}

fileprivate class ZoomData {

    let offset: Size
    let scale: Double
    let angle: Double

    init(offset: Size = Size.zero, scale: Double = 1, angle: Double = 0) {
        self.offset = offset
        self.scale = scale
        self.angle = angle
    }

    func transform() -> Transform {
        return Transform.move(dx: offset.w, dy: offset.h).scale(sx: scale, sy: scale).rotate(angle: angle)
    }

    func move(delta: Size) -> ZoomData {
        return ZoomData(offset: offset + delta, scale: scale, angle: angle)
    }

    func combine(with: ZoomData) -> ZoomData {
        let sina = sin(angle)
        let cosa = cos(angle)
        let w = offset.w + scale * (cosa * with.offset.w - sina * with.offset.h)
        let h = offset.h + scale * (sina * with.offset.w + cosa * with.offset.h)
        let s = scale * with.scale
        let a = angle + with.angle
        return ZoomData(offset: Size(w: w, h: h), scale: s, angle: a)
    }

}

fileprivate class TouchData {

    let touch: MTouch
    let point: Point

    convenience init(touch: MTouch, in view: MView) {
        self.init(touch: touch, point: touch.location(in: view).toMacaw())
    }

    init(touch: MTouch, point: Point) {
        self.touch = touch
        self.point = point
    }

    func current(in view: MView) -> Point {
        return touch.location(in: view).toMacaw()
    }

}
