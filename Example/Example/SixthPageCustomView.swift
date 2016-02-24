import Foundation
import UIKit
import Macaw

class SixthPageCustomView: MacawView {
    
    required init?(node: Node, coder aDecoder: NSCoder) {
        let g = CleanersGraphics()
        super.init(node: g.graphics(.DONE), coder: aDecoder)
    }
}