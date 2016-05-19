import Foundation
import UIKit

public class MacawView: UIView {

	var node: Node!
	var context: RenderContext!
	var renderer: NodeRenderer!

	var animationProducer: AnimationProducer?

	public required init?(node: Node, coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)

		self.node = node
		self.context = RenderContext(view: self)
		self.renderer = RenderUtils.createNodeRenderer(node, context: context)!

		self.animationProducer = AnimationProducer(layer: self.layer)
	}

	public convenience required init?(coder aDecoder: NSCoder) {
		self.init(node: Group(pos: Transform()), coder: aDecoder)
	}

	override public func drawRect(rect: CGRect) {
		self.context.cgContext = UIGraphicsGetCurrentContext()
		renderer.render(false)
	}

	public func addAnimation(animation: Animatable, autoPlay: Bool = true) {

		animationProducer?.addAnimation(animation)
		self.setNeedsDisplay()
	}
}
