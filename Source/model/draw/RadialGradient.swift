import Foundation

#if os(iOS)
  import UIKit
#endif

open class RadialGradient: Gradient {
  
  open var cx: Double
  open var cy: Double
  open var fx: Double
  open var fy: Double
  open let r: Double
  
  public init(cx: Double = 0.5, cy: Double = 0.5, fx: Double = 0.5, fy: Double = 0.5, r: Double = 0.5, userSpace: Bool = false, stops: [Stop] = []) {
    self.cx = cx
    self.cy = cy
    self.fx = fx
    self.fy = fy
    self.r = r
    super.init(
      userSpace: userSpace,
      stops: stops
    )
  }
  
  func applyTransform(_ transform: Transform) {
    // TODO: - Check logic
    
    let cgTransform = RenderUtils.mapTransform(transform)
    
    let point1 = CGPoint(x: cx, y: cy).applying(cgTransform)
    cx = point1.x.doubleValue
    cy = point1.y.doubleValue
    
    let point2 = CGPoint(x: fx, y: fy).applying(cgTransform)
    fx = point2.x.doubleValue
    fy = point2.y.doubleValue
  }
}
