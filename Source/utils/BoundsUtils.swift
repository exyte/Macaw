//
//  BoundsUtils.swift
//  Macaw
//
//  Created by Anton Marunko on 09/06/2018.
//  Copyright © 2018 Exyte. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

final internal class BoundsUtils {
    class func getRect(of image: Image?, mImage: MImage) -> CGRect? {
        guard let image = image else {
            return .none
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

            let newSize = image.aspectRatio.fit(
                size: Size(w: Double(imageSize.width), h: Double(imageSize.height)),
                into: Size(w: w.doubleValue, h: h.doubleValue)
            )
            let destX = image.xAlign.align(outer: w.doubleValue, inner: newSize.w)
            let destY = image.yAlign.align(outer: h.doubleValue, inner: newSize.h)
            return CGRect(x: destX, y: destY, width: newSize.w, height: newSize.h)
        }
    }

    class func getNodesBounds(_ nodes: [Node]) -> Rect? {
        var union: Rect?
        nodes.forEach { node in
            guard let nodeBounds = node.bounds?.applying(node.place) else {
                return
            }
            union = union?.union(rect: nodeBounds) ?? nodeBounds
        }
        return union
    }

    class func transformForLocusInRespectiveCoords(respectiveLocus: Locus, absoluteLocus: Locus) -> Transform {
        let absoluteBounds = absoluteLocus.bounds()
        let respectiveBounds = respectiveLocus.bounds()
        let finalSize = Size(w: absoluteBounds.w * respectiveBounds.w,
                             h: absoluteBounds.h * respectiveBounds.h)
        let scale = ContentLayout.of(contentMode: .scaleToFill).layout(size: respectiveBounds.size(), into: finalSize)
        return Transform.move(dx: absoluteBounds.x, dy: absoluteBounds.y).concat(with: scale)
    }

    class func createNodeFromRespectiveCoords(respectiveNode: Node, absoluteLocus: Locus) -> Node? {
        guard let copy = SceneUtils.copyNode(respectiveNode) else {
            return nil
        }

        if let patternShape = copy as? Shape {
            let tranform = BoundsUtils.transformForLocusInRespectiveCoords(respectiveLocus: patternShape.form, absoluteLocus: absoluteLocus)
            patternShape.place = patternShape.place.concat(with: tranform)
        }
        if let patternGroup = copy as? Group {
            var nodes = [Node]()
            for groupNode in patternGroup.contents {
                if let node = createNodeFromRespectiveCoords(respectiveNode: groupNode, absoluteLocus: absoluteLocus) {
                    nodes.append(node)
                }
            }
            patternGroup.contents = nodes
        }

        return copy
    }
}
