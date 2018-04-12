//
//  SVGCanvas.swift
//  Macaw
//
//  Created by Yuri Strot on 4/11/18.
//

class SVGCanvas: Group {

    private let svgBounds: Rect

    override internal func bounds() -> Rect? {
        return svgBounds
    }

    public init(bounds: Rect, contents: [Node] = []) {
        self.svgBounds = bounds
        super.init(contents: contents)
    }

}
