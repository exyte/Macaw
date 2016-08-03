import Foundation
import UIKit

public class PanEvent: Signal {
    
    public var dx: CGFloat
    public var dy: CGFloat
    
    init(dx: CGFloat, dy: CGFloat) {
        self.dx = dx
        self.dy = dy
    }
    
}