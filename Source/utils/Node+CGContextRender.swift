//
//  NodeToUIImage.swift
//  Macaw
//
//  Created by Simon Corsin on 9/6/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation
import CoreGraphics

public extension Node {

    /**
     Draw the receiver Node in the given rect and CGContext.
     You can use that if you don't want to use MacawView
     or want a way to directly render a Node into a CGBitmapContext
     for instance.
     */
    public func draw(in rect: CGRect, context: CGContext, opacity: Double = 1) {
        let renderContext = RenderContext(view: nil)
        renderContext.cgContext = context
        renderContext.renderRect = rect

        let renderer = RenderUtils.createNodeRenderer(self, context: renderContext, animationCache: nil)
        defer { renderer.dispose() }
        renderer.render(force: true, opacity: opacity)
    }

}
