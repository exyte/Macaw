//
//  BoundsUtils.swift
//  Macaw
//
//  Created by Anton Marunko on 18/12/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

class BoundsUtils {

    class func getRect(image: Image?, mImage: MImage) -> CGRect {
        guard let image = image else {
            return .zero
        }

        let imageSize = mImage.size
        var w = CGFloat(image.w)
        var h = CGFloat(image.h)
        if (w == 0 || w == imageSize.width) && (h == 0 || h == imageSize.height) {
            return CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        } else {
            if w == 0 {
                w = imageSize.width * h / imageSize.height
            } else if h == 0 {
                h = imageSize.height * w / imageSize.width
            }
            switch image.aspectRatio {
            case AspectRatio.meet:
                return calculateMeetAspectRatio(image, size: imageSize)
            case AspectRatio.slice:
                return calculateSliceAspectRatio(image, size: imageSize)
            default:
                return CGRect(x: 0, y: 0, width: w, height: h)
            }
        }
    }

    fileprivate class func calculateMeetAspectRatio(_ image: Image, size: CGSize) -> CGRect {
        let w = CGFloat(image.w)
        let h = CGFloat(image.h)
        // destination and source aspect ratios
        let destAR = w / h
        let srcAR = size.width / size.height
        var resultW = w
        var resultH = h
        var destX = CGFloat(0)
        var destY = CGFloat(0)
        if destAR < srcAR {
            // fill all available width and scale height
            resultH = size.height * w / size.width
        } else {
            // fill all available height and scale width
            resultW = size.width * h / size.height
        }
        let xalign = image.xAlign
        switch xalign {
        case Align.min:
            destX = 0
        case Align.mid:
            destX = w / 2 - resultW / 2
        case Align.max:
            destX = w - resultW
        }
        let yalign = image.yAlign
        switch yalign {
        case Align.min:
            destY = 0
        case Align.mid:
            destY = h / 2 - resultH / 2
        case Align.max:
            destY = h - resultH
        }
        return CGRect(x: destX, y: destY, width: resultW, height: resultH)
    }

    fileprivate class func calculateSliceAspectRatio(_ image: Image, size: CGSize) -> CGRect {
        let w = CGFloat(image.w)
        let h = CGFloat(image.h)
        var srcX = CGFloat(0)
        var srcY = CGFloat(0)
        var totalH: CGFloat = 0
        var totalW: CGFloat = 0
        // destination and source aspect ratios
        let destAR = w / h
        let srcAR = size.width / size.height
        if destAR > srcAR {
            // fill all available width and scale height
            totalH = size.height * w / size.width
            totalW = w
            switch image.yAlign {
            case Align.min:
                srcY = 0
            case Align.mid:
                srcY = -(totalH / 2 - h / 2)
            case Align.max:
                srcY = -(totalH - h)
            }
        } else {
            // fill all available height and scale width
            totalW = size.width * h / size.height
            totalH = h
            switch image.xAlign {
            case Align.min:
                srcX = 0
            case Align.mid:
                srcX = -(totalW / 2 - w / 2)
            case Align.max:
                srcX = -(totalW - w)
            }
        }
        return CGRect(x: srcX, y: srcY, width: totalW, height: totalH)
    }

    class func getBounds(image: Image) -> Rect {

        var mImage: MImage?

        if image.src.contains("memory") {
            let id = image.src.replacingOccurrences(of: "memory://", with: "")
            mImage = imagesMap[id]
        } else {
            mImage = image.image()
        }

        if let mImage = mImage {
            let rect = getRect(image: image, mImage: mImage)
            return Rect(cgRect: rect)
        } else {
            return Rect.zero()
        }
    }
}
