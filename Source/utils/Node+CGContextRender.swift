//
//  NodeToUIImage.swift
//  Macaw
//
//  Created by Simon Corsin on 9/6/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

public extension Node {

    public func draw(in rect: CGRect, context: CGContext, opacity: Double = 1) {
        let renderContext = RenderContext(view: nil)
        renderContext.cgContext = context
        renderContext.renderRect = rect

        let renderer = RenderUtils.createNodeRenderer(self, context: renderContext, animationCache: nil)
        defer { renderer.dispose() }
        renderer.render(force: true, opacity: opacity)
    }

}
