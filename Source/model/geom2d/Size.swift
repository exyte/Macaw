import Foundation

open class Size {

    open let w: Double
    open let h: Double

    public init(w: Double = 0, h: Double = 0) {
        self.w = w
        self.h = h
    }
    
    func aspectFit(_ rectToFitIn: Rect) -> Rect {
        let widthRatio = rectToFitIn.w / w
        let heightRatio = rectToFitIn.h / h
        
        var newWidth = rectToFitIn.w
        var newHeight = rectToFitIn.h
        if( heightRatio < widthRatio ) {
            newWidth = w * heightRatio
        }
        else if( widthRatio < heightRatio ) {
            newHeight = h * widthRatio
        }
        
        let newX = rectToFitIn.x + rectToFitIn.w / 2 - newWidth / 2
        let newY = rectToFitIn.y + rectToFitIn.h / 2 - newHeight / 2
        
        return Rect(x: newX, y: newY, w: newWidth, h: newHeight)
    }
}
