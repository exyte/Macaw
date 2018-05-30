//
//  UIImageExtensions.swift
//  Macaw
//
//  Created by Eugene Nazarov on 5/30/18.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#endif

public extension UIImage {

    convenience init?(SVGFile filename: String, bundle: Bundle, maxSize: Size) {
        guard
            let rootNode = try? SVGParser.parse(bundle: bundle, path: filename),
            let nodeRect = rootNode.bounds() else { return nil }

        let horizontalRatio = maxSize.w / nodeRect.w
        let verticalRatio = maxSize.h / nodeRect.h

        let ratio = min(horizontalRatio, verticalRatio)
        let rect = Rect(x: 0, y: 0, w: nodeRect.w * ratio, h: nodeRect.h * ratio)

        let renderer = RenderUtils.createNodeRenderer(rootNode, animationCache: nil)

        if let cgImage = renderer.renderToImage(bounds: rect, inset: 0)?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }

}
