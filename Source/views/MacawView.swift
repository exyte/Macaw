import Foundation
import UIKit

///
/// MacawView is a main class used to embed Macaw scene into your Cocoa UI.
/// You could create your own view extended from MacawView with predefined scene.
///
public class MacawView: UIView {

	/// Scene root node
	public var node: Node = Group() {
		didSet {
			self.renderer = RenderUtils.createNodeRenderer(node, context: context, animationCache: animationCache)
		}
	}

	private var selectedShape: Shape? = nil

	var context: RenderContext!
	var renderer: NodeRenderer?

	var animationProducer: AnimationProducer?

	var toRender = true

	private let animationCache = AnimationCache()

	public init?(node: Node, coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)

		self.context = RenderContext(view: self)
		self.node = node
		self.animationProducer = AnimationProducer(layer: self.layer, animationCache: animationCache)
		self.renderer = RenderUtils.createNodeRenderer(node, context: context, animationCache: animationCache)

		let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MacawView.handlePan))
		let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(MacawView.handleRotation))
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(MacawView.handlePinch))
		self.addGestureRecognizer(panRecognizer)
		self.addGestureRecognizer(rotationRecognizer)
		self.addGestureRecognizer(pinchRecognizer)
	}

	public convenience required init?(coder aDecoder: NSCoder) {
		self.init(node: Group(), coder: aDecoder)
	}

	override public func drawRect(rect: CGRect) {
		self.context.cgContext = UIGraphicsGetCurrentContext()
		renderer?.render(false, opacity: node.opacity)
	}

	public func addAnimation(animation: Animatable, autoPlay: Bool = true) {
		animationProducer?.addAnimation(animation)
	}

	public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.selectedShape = nil
		for touch in touches {
			let location = touch.locationInView(self)
			let shapes = renderer?.detectTouches(location)
			self.selectedShape = shapes?.first
			if let shape = self.selectedShape {
				shape.onTap.onNext(TapEvent(location: location))
			}
		}
	}

	func handlePan(recognizer: UIPanGestureRecognizer) {
		var translation = recognizer.translationInView(self)
		recognizer.setTranslation(CGPointZero, inView: self)
		if let shape = self.selectedShape {
			// get the rotation and scale of the shape and apply to the translation
			let transform = shape.pos
			let rotation = -CGFloat(atan2f(Float(transform.m12), Float(transform.m11)))
			let scale = CGFloat(sqrt(transform.m11 * transform.m11 + transform.m21 * transform.m21))
			var translatedLocation = CGPointApplyAffineTransform(translation, CGAffineTransformMakeRotation(rotation))
			shape.onPan.onNext(PanEvent(dx: translatedLocation.x / scale, dy: translatedLocation.y / scale))
		}
		setNeedsDisplay()
	}

	func handleRotation(recognizer: UIRotationGestureRecognizer) {
		let rotation = recognizer.rotation
		recognizer.rotation = 0
		if let shape = self.selectedShape {
			shape.onRotate.onNext(RotateEvent(radians: rotation))
		}
		setNeedsDisplay()
	}

	func handlePinch(recognizer: UIPinchGestureRecognizer) {
		let scale = recognizer.scale
		recognizer.scale = 1
		if let shape = self.selectedShape {
			shape.onPinch.onNext(PinchEvent(scale: scale))
		}
		setNeedsDisplay()
	}

}