//
//  ContentLayout.swift
//  Macaw
//
//  Created by Yuri Strot on 5/17/18.
//  Copyright © 2018 Exyte. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

open class ContentLayout {

    public static let none: ContentLayout = NoneLayout()

    public static func of(scaling: AspectRatio = .meet, xAlign: Align = .mid, yAlign: Align = .mid) -> ContentLayout {
        return ScalingContentLayout(scaling: scaling, xAlign: xAlign, yAlign: yAlign)
    }

    public static func of(contentMode: MViewContentMode) -> ContentLayout {
        switch contentMode {
        case .scaleToFill:
            return of(scaling: .none)
        case .scaleAspectFit:
            return of(scaling: .meet)
        case .scaleAspectFill:
            return of(scaling: .slice)
        case .redraw, .center:
            return of(scaling: .doNothing)
        case .top:
            return of(scaling: .doNothing, yAlign: .min)
        case .bottom:
            return of(scaling: .doNothing, yAlign: .max)
        case .left:
            return of(scaling: .doNothing, xAlign: .min)
        case .right:
            return of(scaling: .doNothing, xAlign: .max)
        case .topLeft:
            return of(scaling: .doNothing, xAlign: .min, yAlign: .min)
        case .topRight:
            return of(scaling: .doNothing, xAlign: .max, yAlign: .min)
        case .bottomLeft:
            return of(scaling: .doNothing, xAlign: .min, yAlign: .max)
        case .bottomRight:
            return of(scaling: .doNothing, xAlign: .max, yAlign: .max)
        }
    }

    public init() {
    }

    open func layout(size: Size, into sizeToFitIn: Size) -> Transform {
        return layout(rect: size.rect(), into: sizeToFitIn)
    }

    open func layout(rect: Rect, into sizeToFitIn: Size) -> Transform {
        return Transform.identity
    }

}

class NoneLayout: ContentLayout {

}

class ScalingContentLayout: ContentLayout {

    let scaling: AspectRatio
    let xAlign: Align
    let yAlign: Align

    init(scaling: AspectRatio, xAlign: Align, yAlign: Align) {
        self.scaling = scaling
        self.xAlign = xAlign
        self.yAlign = yAlign
    }

    open override func layout(rect: Rect, into sizeToFitIn: Size) -> Transform {
        let newSize = scaling.fit(size: rect.size(), into: sizeToFitIn)
        let sx = newSize.w / rect.w
        let sy = newSize.h / rect.h
        let dx = xAlign.align(outer: sizeToFitIn.w, inner: newSize.w) / sx
        let dy = yAlign.align(outer: sizeToFitIn.h, inner: newSize.h) / sy
        return Transform.scale(sx: sx, sy: sy).move(dx: dx - rect.x, dy: dy - rect.y)
    }
}
