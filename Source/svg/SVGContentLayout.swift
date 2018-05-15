
public protocol ContentLayout {
    
    static var standard: ContentLayout { get }
    func layout(rect: Rect, into rectToFitIn: Rect) -> Transform
}

class SVGContentLayout: ContentLayout {
    
    let scalingMode: AspectRatio
    let xAligningMode: Align
    let yAligningMode: Align
    
    init(scalingMode: AspectRatio? = .meet, xAligningMode: Align? = .mid, yAligningMode: Align? = .mid) {
        self.scalingMode = scalingMode ?? .meet
        self.xAligningMode = xAligningMode ?? .mid
        self.yAligningMode = yAligningMode ?? .mid
    }
    
    public static var standard: ContentLayout {
        return SVGContentLayout()
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
