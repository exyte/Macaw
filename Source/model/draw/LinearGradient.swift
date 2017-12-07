import Foundation

#if os(iOS)
    import UIKit
#endif

open class LinearGradient: Gradient {

    open var x1: Double
    open var y1: Double
    open var x2: Double
    open var y2: Double

    /// Inits a LinearGradient with your own parameters.
    ///
    /// You can pass more than two colors and you can control, where the positions of these colors are (by adding multiple `Stop`).
    ///
    /// When `userSpace` is true, direction line will be declared in the node coordinate system.
    ///
    /// Otherwise (if `userSpace` is false), the abstract coordinate system will be used where
    ///
    /// (0,0) is at the top left corner of the node bounding box
    ///
    /// (1,1) is at the bottom right corner of the node bounding box.
    ///
    /// - Parameters:
    ///   - x1: The first x value of the CGPoint
    ///   - y1: The first y value of the CGPoint
    ///   - x2: The second x value of the CGPoint
    ///   - y2: The second y value of the CGPoint
    ///   - userSpace: If true, direction line will be declared in the node coordinate system, if false, the abstract coordinate system will be used where
    ///   - stops: An array of `Stop` (`Stop` has two properties: 1) offset as Double and 2) color as Color)
    ///
    /// -------
    ///
    /// *Example*:
    ///
    ///     let fill = LinearGradient(x1: 0,
    ///                               y1: 0,
    ///                               x2: 0,
    ///                               y2: 1,
    ///                               userSpace: false,
    ///                               stops: [
    ///                                    Stop(offset: 0, color: Color(val: 0xfcc07c)),
    ///                                    Stop(offset: 1, color: Color(val: 0xfc7600))])
    public init(x1: Double = 0, y1: Double = 0, x2: Double = 0, y2: Double = 0, userSpace: Bool = false, stops: [Stop] = []) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        super.init(
            userSpace: userSpace,
            stops: stops
        )
    }

    /// Inits a LinearGradient with a degree (optional) and with multiple Stops.
    ///
    /// - Parameters:
    ///   - degree: If 0, the Gradient is drawn from the left to the right (default). 90.0 is from top to bottom (and so on).
    ///   - stops: An array of Stop (Stop has two properties: 1) offset as Double and 2) color as Color).
    ///
    /// *Example*:
    ///
    ///     let gradient = LinearGradient(degree: 90,
    ///                                   stops: [
    ///                                       Stop(offset: 0.2, color: Color.black),
    ///                                       Stop(offset: 0.4, color: Color.white),
    ///                                       Stop(offset: 0.6, color: Color.black)])
    public init(degree: Double = 0, stops: [Stop]) {
        self.x1 = degree >= 135 && degree < 270 ? 1 : 0
        self.y1 = degree < 225 ? 0 : 1
        self.x2 = degree < 90 || degree >= 315 ? 1 : 0
        self.y2 = degree >= 45 && degree < 180 ? 1 : 0
        super.init(
            userSpace: false,
            stops: stops
        )
    }
    
    /// Inits a LinearGradient with a degree
    ///
    /// - Parameters:
    ///   - degree: If 0, the Gradient is drawn from the left to the right (default). 90.0 is from top to bottom (and so on).
    ///   - from: The first `Color` of the Gradient.
    ///   - to: The second `Color` of the Gradient.
    ///
    /// *Example* (draws a gradient from the top to the bottom):
    ///
    ///     let gradient = LinearGradient(degree: 90.0,
    ///                                   from: Color.white,
    ///                                   to: Color.black)
    public init(degree: Double = 0, from: Color, to: Color) {
        self.x1 = degree >= 135 && degree < 270 ? 1 : 0
        self.y1 = degree < 225 ? 0 : 1
        self.x2 = degree < 90 || degree >= 315 ? 1 : 0
        self.y2 = degree >= 45 && degree < 180 ? 1 : 0
        super.init(
            userSpace: false,
            stops: [Stop(offset: 0, color: from), Stop(offset: 1, color: to)]
        )
    }

    func applyTransform(_ transform: Transform) {
        // TODO: - Check logic

        let cgTransform = RenderUtils.mapTransform(transform)

        let point1 = CGPoint(x: x1, y: y1).applying(cgTransform)
        x1 = point1.x.doubleValue
        y1 = point1.y.doubleValue

        let point2 = CGPoint(x: x2, y: y2).applying(cgTransform)
        x2 = point2.x.doubleValue
        y2 = point2.y.doubleValue
        
    }

}
