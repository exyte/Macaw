
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

public protocol NodeLayout {
    
    func layout(in rect: Rect) -> (Transform, Locus?)
}

class SvgNodeLayout: NodeLayout {
    
    let svgDimensions: Dimensions?
    let viewBox: Rect?
    let scalingMode: AspectRatio
    let xAligningMode: Align
    let yAligningMode: Align
    
    init(svgDimensions: Dimensions? = .none, viewBox: Rect? = .none, scalingMode: AspectRatio? = .meet, xAligningMode: Align? = .mid, yAligningMode: Align? = .mid) {
        self.svgDimensions = svgDimensions
        self.viewBox = viewBox
        self.scalingMode = scalingMode ?? .meet
        self.xAligningMode = xAligningMode ?? .mid
        self.yAligningMode = yAligningMode ?? .mid
    }
    
    public func layout(in rect: Rect) -> (Transform, Locus?) {
        
        var clip: Locus? = .none
        var transform = Transform.identity
        
        guard let dimensions = svgDimensions else {
            return (transform, clip)
        }
        
        let width = dimensionToPixels(dimensions.width, framePixels: rect.w)
        let height = dimensionToPixels(dimensions.height, framePixels: rect.h)
        let svgSize = Size(w: width, h: height)
        
        if let viewBox = self.viewBox {
            clip = viewBox
        }
        let viewBox = self.viewBox ?? Rect(x: 0, y: 0, w: svgSize.w, h: svgSize.h)
        
        if scalingMode === AspectRatio.slice {
            // setup new clipping to slice extra bits
            let newSize = AspectRatio.meet.fit(size: svgSize, into: viewBox)
            let newX = viewBox.x + xAligningMode.align(outer: viewBox.w, inner: newSize.w)
            let newY = viewBox.y + yAligningMode.align(outer: viewBox.h, inner: newSize.h)
            clip = Rect(x: newX, y: newY, w: newSize.w, h: newSize.h)
        }
        
        let contentLayout = SvgContentLayout(scalingMode: scalingMode, xAligningMode: xAligningMode, yAligningMode: yAligningMode)
        transform = contentLayout.layout(rect: viewBox, into: Rect(x: 0, y: 0, w: svgSize.w, h: svgSize.h))
        
        // move to (0, 0)
        transform = transform.move(dx: -viewBox.x, dy: -viewBox.y)
        return (transform, clip)
    }
}

fileprivate func dimensionToPixels(_ dimension: Dimension, framePixels: Double) -> Double {
    switch(dimension) {
    case let .percent(percent):
        return framePixels * percent / 100.0
    case let .pixels(pixels):
        return pixels
    }
}
