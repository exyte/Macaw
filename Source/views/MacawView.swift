import Foundation
import UIKit

public class MacawView: UIView {

	var node: Node!
	var context: RenderContext!
	var renderer: NodeRenderer!
	// var loop: AnimationLoop?
	var animationProducer: AnimationProducer?

	public required init?(node: Node, coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)

		self.node = node
		self.context = RenderContext(view: self)
		self.renderer = RenderUtils.createNodeRenderer(node, context: context)!

		self.animationProducer = AnimationProducer(layer: self.layer)
//		self.loop = AnimationLoop()
//		self.loop?.rendererCall = {
//			self.setNeedsDisplay()
//		}
	}

	public convenience required init?(coder aDecoder: NSCoder) {
		self.init(node: Group(pos: Transform()), coder: aDecoder)
	}

	override public func drawRect(rect: CGRect) {
		self.context.cgContext = UIGraphicsGetCurrentContext()
		renderer.render()
	}

	public func addAnimation(animation: Animatable, autoPlay: Bool = true) {
		// let subscription = AnimationSubscription(animation: animation, paused: !autoPlay)
		// self.loop?.addSubscription(subscription)
		animationProducer?.addAnimation(animation)
		self.setNeedsDisplay()
	}
}
