import Foundation
import UIKit

public class MacawView: UIView {

    let node: Node

    public required init?(node: Node, coder aDecoder: NSCoder) {
        self.node = node
        super.init(coder: aDecoder)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init(node: Group(pos: Transform()), coder: aDecoder)
    }

    override public func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        drawNode(node, ctx: ctx!)
    }

    private func drawNode(node: Node, ctx: CGContext) {
        if node.visible == true {
            CGContextSaveGState(ctx)
            CGContextConcatCTM(ctx, RenderUtils.mapTransform(node.pos))

            if let group = node as? Group {
                for content in group.contents {
                    drawNode(content, ctx: ctx)
                }
            } else if let renderer = createRenderer(node, ctx: ctx) {
                renderer.render()
            }

            CGContextRestoreGState(ctx)
        }
    }
    
    func createRenderer(node: Node, ctx: CGContext) -> NodeRenderer? {
        if let shape = node as? Shape {
            return ShapeRenderer(shape: shape, ctx: ctx)
        } else if let text = node as? Text {
            return TextRenderer(text: text, ctx: ctx)
        } else if let image = node as? Image {
            return ImageRenderer(image: image, ctx: ctx)
        }
        print("Unsupported node: \(node)")
        return nil
    }
}
