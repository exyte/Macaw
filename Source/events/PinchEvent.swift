import Foundation
import UIKit

public class PinchEvent: Signal {
    
    public var scale: CGFloat
    
    init(scale: CGFloat) {
        self.scale = scale
    }
    
}