//
//  MacawView+PDF.swift
//  Macaw
//
//  Created by Victor Sukochev on 06/10/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation
import CoreGraphics

public extension MacawView {
    func toPDF(size: CGSize, path: URL) {
        let currentColor = backgroundColor
        backgroundColor = MColor.white
        defer {
            backgroundColor = currentColor
        }

        var frame = CGRect(origin: CGPoint.zero, size: size)
        let ctx = CGContext(path as CFURL, mediaBox: &frame, .none)!

        ctx.beginPDFPage(.none)
        ctx.translateBy(x: 0.0, y: size.height)
        ctx.scaleBy(
            x: size.width / bounds.width,
            y: -size.height / bounds.height
        )

        drawingView.context.cgContext = ctx
        drawingView.renderer?.render(in: ctx, force: false, opacity: node.opacity)

        ctx.endPDFPage()
    }
}
