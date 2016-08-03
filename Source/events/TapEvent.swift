import Foundation
import UIKit

public class TapEvent: Signal {
    
    public var location: CGPoint
    
    init(location: CGPoint) {
        self.location = location
    }
    
}