
public protocol ContentLayout {
    
    static var standard: ContentLayout { get }
    func layout(rect: Rect, into rectToFitIn: Rect) -> Transform
}

open class SvgContentLayout: ContentLayout {
    
    public let scalingMode: AspectRatio!
    public let xAligningMode: Align!
    public let yAligningMode: Align!
    
    public init(scalingMode: AspectRatio, xAligningMode: Align? = Align.min, yAligningMode: Align? = Align.min) {
        self.scalingMode = scalingMode
        self.xAligningMode = xAligningMode
        self.yAligningMode = yAligningMode
    }
    
    public static var standard: ContentLayout {
        return SvgContentLayout(scalingMode: .none)
    }
    
    public func layout(rect: Rect, into rectToFitIn: Rect) -> Transform {
        
        var result = Transform()
        guard let scalingMode = scalingMode else { return result }
        let r = Rect(x: 0, y: 0, w: rect.x + rect.w, h: rect.y + rect.h)
        
        let newSize = scalingMode.fit(rect: r, into: rectToFitIn)
        result = result.scale(
            sx: newSize.w / r.w,
            sy: newSize.h / r.h
        )
        
        let dx = xAligningMode.align(outer: rectToFitIn.w, inner: newSize.w) / (newSize.w / r.w)
        let dy = yAligningMode.align(outer: rectToFitIn.h, inner: newSize.h) / (newSize.h / r.h)
        result = result.move(dx: dx, dy: dy)
        
        return result
    }
}
