
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
        
        let widthRatio = rectToFitIn.w / rect.w
        let heightRatio = rectToFitIn.h / rect.h
        
        var newWidth = rectToFitIn.w
        var newHeight = rectToFitIn.h
        
        switch scalingMode {
        case .meet:
            if heightRatio < widthRatio {
                newWidth = rect.w * heightRatio
            } else {
                newHeight = rect.h * widthRatio
            }
            result = result.scale(
                sx: newWidth / rect.w,
                sy: newHeight / rect.h
            )
        case .slice:
            if heightRatio > widthRatio {
                newWidth = rect.w * heightRatio
            } else {
                newHeight = rect.h * widthRatio
            }
            result = result.scale(
                sx: newWidth / rect.w,
                sy: newHeight / rect.h
            )
        case .none:
            result = result.scale(
                sx: Double(widthRatio),
                sy: Double(heightRatio)
            )
        }
        
        let dx = xAligningMode.align(x: rectToFitIn.w, y: newWidth) / (newWidth / rect.w)
        let dy = yAligningMode.align(x: rectToFitIn.h, y: newHeight) / (newHeight / rect.h)
        result = result.move(dx: dx, dy: dy)
        
        return result
    }
}
