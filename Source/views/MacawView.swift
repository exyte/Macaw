import Foundation
import UIKit

public class MacawView: UIView {

    var node: Node!
    var context: RenderContext!
    var renderer: NodeRenderer!
    
    public required init?(node: Node, coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.node = node
        self.context = RenderContext(view: self)
        self.renderer = RenderUtils.createNodeRenderer(node, context: context)!

    }

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init(node: Group(pos: Transform()), coder: aDecoder)
    }

    override public func drawRect(rect: CGRect) {
        self.context.cgContext = UIGraphicsGetCurrentContext()
        renderer.render()
    }
}
