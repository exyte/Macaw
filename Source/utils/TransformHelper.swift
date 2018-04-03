
public protocol TransformHelperProtocol {
    
    static var standard: TransformHelperProtocol { get }
    func getTransformOf(_ rect: Rect, into rectToFitIn: Rect) -> Transform
}

open class TransformHelper: TransformHelperProtocol {
    
    public let scalingMode: AspectRatio!
    public let xAligningMode: Align!
    public let yAligningMode: Align!
    
    public init(scalingMode: AspectRatio, xAligningMode: Align? = Align.min, yAligningMode: Align? = Align.min) {
        self.scalingMode = scalingMode
        self.xAligningMode = xAligningMode
        self.yAligningMode = yAligningMode
    }
    
    public static var standard: TransformHelperProtocol {
        return TransformHelper(scalingMode: .none)
    }
    
    public func getTransformOf(_ rect: Rect, into rectToFitIn: Rect) -> Transform {
        
        var result = Transform()
        guard let scalingMode = scalingMode else { return result }
        
        let newSize = scalingMode.fit(rect: rect, into: rectToFitIn)
        result = result.scale(
            sx: newSize.w / rect.w,
            sy: newSize.h / rect.h
        )
        
        let dx = xAligningMode.align(x: rectToFitIn.w, y: newSize.w) / (newSize.w / rect.w)
        let dy = yAligningMode.align(x: rectToFitIn.h, y: newSize.h) / (newSize.h / rect.h)
        result = result.move(dx: dx, dy: dy)
        
        return result
    }
}
