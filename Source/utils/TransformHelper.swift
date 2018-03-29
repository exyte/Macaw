
public enum AlignMode : String {
    case max
    case mid
    case min
}

public enum ScaleMode : String {
    case aspectFit = "meet"
    case aspectFill = "slice"
    case scaleToFill = "none"
}

public protocol TransformHelperProtocol {
    
    var scalingMode: ScaleMode? { get set }
    var xAligningMode: AlignMode? { get set }
    var yAligningMode: AlignMode? { get set }
    
    func getTransformOf(_ rect: Rect, into rectToFitIn: Rect) -> Transform
}

open class TransformHelper: TransformHelperProtocol {
    
    public var scalingMode: ScaleMode?
    public var xAligningMode: AlignMode?
    public var yAligningMode: AlignMode?
    
    public init() { }
    
    public func getTransformOf(_ rect: Rect, into rectToFitIn: Rect) -> Transform {
        
        var result = Transform()
        guard let scalingMode = scalingMode else { return result }
        
        let widthRatio = rectToFitIn.w / rect.w
        let heightRatio = rectToFitIn.h / rect.h
        
        var newWidth = rectToFitIn.w
        var newHeight = rectToFitIn.h
        
        switch scalingMode {
        case .aspectFit:
            if heightRatio < widthRatio {
                newWidth = rect.w * heightRatio
            } else {
                newHeight = rect.h * widthRatio
            }
            result = result.scale(
                sx: newWidth / rect.w,
                sy: newHeight / rect.h
            )
        case .aspectFill:
            if heightRatio > widthRatio {
                newWidth = rect.w * heightRatio
            } else {
                newHeight = rect.h * widthRatio
            }
            result = result.scale(
                sx: newWidth / rect.w,
                sy: newHeight / rect.h
            )
        case .scaleToFill:
            result = result.scale(
                sx: Double(widthRatio),
                sy: Double(heightRatio)
            )
        }
        
        guard let xAligningMode = xAligningMode else { return result }
        switch xAligningMode {
        case .min:
            break
        case .mid:
            result = result.move(
                dx: (rectToFitIn.w / 2 - newWidth / 2) / (newWidth / rect.w),
                dy: 0
            )
        case .max:
            result = result.move(
                dx: (rectToFitIn.w - newWidth) / (newWidth / rect.w),
                dy: 0
            )
        }
        
        guard let yAligningMode = yAligningMode else { return result }
        switch yAligningMode {
        case .min:
            break
        case .mid:
            result = result.move(
                dx: 0,
                dy: (rectToFitIn.h / 2 - newHeight / 2) / (newHeight / rect.h)
            )
        case .max:
            result = result.move(
                dx: 0,
                dy: (rectToFitIn.h - newHeight) / (newHeight / rect.h)
            )
        }
        
        return result
    }
}
