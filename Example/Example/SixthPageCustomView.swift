import Foundation
import UIKit
import Macaw

class SixthPageCustomView: MacawView {
    
    var node: Group
    
    required init?(node: Node, coder aDecoder: NSCoder) {
        let group = Group()
//        let g = CleanersGraphics()
//        group.contents.append(g.graphics(.PICKUP_REQUESTED))
        
        self.node = group
        super.init(node: group, coder: aDecoder)
    }
}