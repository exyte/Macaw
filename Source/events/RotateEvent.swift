import Foundation
import UIKit

public class RotateEvent: Signal {
    
    public var radians: CGFloat
    
    init(radians: CGFloat) {
        self.radians = radians
    }
    
}