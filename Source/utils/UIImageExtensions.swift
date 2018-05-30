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

    convenience init?(SVGFile filename: String, bundle: Bundle, maxSize: CGSize) {

//        defer {
//            UIGraphicsEndImageContext()
//        }

        guard
            let rootNode = try? SVGParser.parse(bundle: bundle, path: filename),
            let nodeRect = rootNode.bounds()?.toCG() else { return nil }

        let horizontalRatio = maxSize.width / nodeRect.width
        let verticalRatio = maxSize.height / nodeRect.height

        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: nodeRect.width * ratio, height: nodeRect.height * ratio)
//
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
//
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let renderer = RenderUtils.createNodeRenderer(rootNode, animationCache: nil)

        let rect = Rect(x: 0, y: 0, w: Double(newSize.width), h: Double(newSize.height))



        if let cgImage = renderer.renderToImage(bounds: rect, inset: 0)?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }

}
