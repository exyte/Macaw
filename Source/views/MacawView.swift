import Foundation
import UIKit

public class MacawView: UIView {

	public var node: Node? {
		didSet {
			guard let validNode = node else {
				return
			}

			self.renderer = RenderUtils.createNodeRenderer(validNode, context: context)
		}
	}

	var context: RenderContext!
	var renderer: NodeRenderer?

	var animationProducer: AnimationProducer?

	public required init?(node: Node?, coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)

		self.context = RenderContext(view: self)
		self.node = node
		self.animationProducer = AnimationProducer(layer: self.layer)

		if let validNode = node {
			self.renderer = RenderUtils.createNodeRenderer(validNode, context: context)
		}
	}

	public convenience required init?(coder aDecoder: NSCoder) {
		self.init(node: Group(pos: Transform()), coder: aDecoder)
	}

	override public func drawRect(rect: CGRect) {
		self.context.cgContext = UIGraphicsGetCurrentContext()

		if let node = node {
			renderer?.render(false, opacity: node.opacity)
		} else {
			renderer?.render(false, opacity: 1.0)
		}
	}

	public func addAnimation(animation: Animatable, autoPlay: Bool = true) {

		animationProducer?.addAnimation(animation)
		self.setNeedsDisplay()
	}
}
