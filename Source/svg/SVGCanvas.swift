//
//  SVGCanvas.swift
//  Macaw
//
//  Created by Yuri Strot on 4/11/18.
//

enum Dimension {
    case percent(Double)
    case pixels(Double)
    
    init(percent: Double) {
        self = .percent(percent)
    }
    
    init(pixels: Double) {
        self = .pixels(pixels)
    }
}

class Dimensions {
    let width: Dimension
    let height: Dimension
    
    public init(width: Dimension, height: Dimension) {
        self.width = width
        self.height = height
    }
}

class ViewBoxParams {
    let svgDimensions: Dimensions?
    let viewBox: Rect?
    let scalingMode: AspectRatio
    let xAligningMode: Align
    let yAligningMode: Align
    
    public init(svgDimensions: Dimensions?, viewBox: Rect?, scalingMode: AspectRatio?, xAligningMode: Align? = .mid, yAligningMode: Align? = .mid) {
        self.svgDimensions = svgDimensions
        self.viewBox = viewBox
        self.scalingMode = scalingMode ?? .meet
        self.xAligningMode = xAligningMode ?? .mid
        self.yAligningMode = yAligningMode ?? .mid
    }
}

class SVGCanvas: Group {
    
    let viewBoxParams: ViewBoxParams

    public init(viewBoxParams: ViewBoxParams, contents: [Node] = []) {
        self.viewBoxParams = viewBoxParams
        super.init(contents: contents)
    }

}
