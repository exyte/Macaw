
public enum Dimension {
    case percent(Double)
    case pixels(Double)
    
    init(percent: Double) {
        self = .percent(percent)
    }
    
    init(pixels: Double) {
        self = .pixels(pixels)
    }
}

public class Dimensions {
    let width: Dimension
    let height: Dimension
    
    public init(width: Dimension, height: Dimension) {
        self.width = width
        self.height = height
    }
}

public protocol ContentLayout {
    
    static var standard: ContentLayout { get }
    func layout(rect: Rect, into rectToFitIn: Rect) -> Transform
}

open class SvgContentLayout: ContentLayout {
    
    public let svgDimensions: Dimensions?
    public let viewBox: Rect?
    public let scalingMode: AspectRatio
    public let xAligningMode: Align
    public let yAligningMode: Align
    
    public init(svgDimensions: Dimensions? = .none, viewBox: Rect? = .none, scalingMode: AspectRatio? = .meet, xAligningMode: Align? = .mid, yAligningMode: Align? = .mid) {
        self.svgDimensions = svgDimensions
        self.viewBox = viewBox
        self.scalingMode = scalingMode ?? .meet
        self.xAligningMode = xAligningMode ?? .mid
        self.yAligningMode = yAligningMode ?? .mid
    }
    
    public static var standard: ContentLayout {
        return SvgContentLayout()
    }
    
    public func layout(rect: Rect, into rectToFitIn: Rect) -> Transform {
        
        var result = Transform()
        let newSize = scalingMode.fit(rect: rect, into: rectToFitIn)
        result = result.scale(
            sx: newSize.w / rect.w,
            sy: newSize.h / rect.h
        )
        
        let dx = xAligningMode.align(outer: rectToFitIn.w, inner: newSize.w) / (newSize.w / rect.w)
        let dy = yAligningMode.align(outer: rectToFitIn.h, inner: newSize.h) / (newSize.h / rect.h)
        result = result.move(dx: dx, dy: dy)
        
        return result
    }
}
