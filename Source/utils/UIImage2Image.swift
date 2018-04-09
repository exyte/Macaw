//
//  UIImage2Image.swift
//  Pods
//
//  Created by Victor Sukochev on 14/04/2017.
//
//

import Foundation

#if os(iOS)
import UIKit
#endif

var imagesMap = [String: MImage]()

public extension MImage {
    public func image( xAlign: Align = .min, yAlign: Align = .min, aspectRatio: AspectRatio = .none, w: Int = 0, h: Int = 0, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) -> Image {

        var oldId: String?
        for key in imagesMap.keys where self === imagesMap[key] {
            oldId = key
        }

        let id = oldId ?? UUID().uuidString
        imagesMap[id] = self

        return Image(src: "memory://\(id)",
            xAlign: xAlign, yAlign: yAlign,
            aspectRatio: aspectRatio,
            w: w, h: h,
            place: place,
            opaque: opaque,
            opacity: opacity,
            clip: clip,
            effect: effect,
            visible: visible,
            tag: tag)
    }
}
