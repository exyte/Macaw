import Foundation
import UIKit

///
/// MacawView is a main class used to embed Macaw scene into your Cocoa UI.
/// You could create your own view extended from MacawView with predefined scene.
///
public class MacawView: UIView {

	/// Scene root node
	public var node: Node = Group() {
		willSet {
			nodesMap.remove(node)
		}

		didSet {
			nodesMap.add(node, view: self)
			self.renderer?.dispose()
			if let cache = animationCache {
				self.renderer = RenderUtils.createNodeRenderer(node, context: context, animationCache: cache)
			}
		}
	}

	private var selectedShape: Shape? = nil

	var context: RenderContext!
	var renderer: NodeRenderer?

	var toRender = true

	internal var animationCache: AnimationCache?

	public init?(node: Node, coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)

		self.context = RenderContext(view: self)
		self.node = node
		self.animationCache = AnimationCache(sceneLayer: self.layer)

		nodesMap.add(node, view: self)
		if let cache = self.animationCache {
			self.renderer = RenderUtils.createNodeRenderer(node, context: context, animationCache: cache)
		}

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

		CGContextSaveGState(self.context.cgContext)
		CGContextConcatCTM(self.context.cgContext, RenderUtils.mapTransform(node.place))
		renderer?.render(false, opacity: node.opacity)
		CGContextRestoreGState(self.context.cgContext)
	}

	public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.selectedShape = nil
		if let inverted = node.place.invert() {
			for touch in touches {
				let location = touch.locationInView(self)
				let translatedLocation = CGPointApplyAffineTransform(location, RenderUtils.mapTransform(inverted))
				let offsetLocation = CGPoint(x: translatedLocation.x, y: translatedLocation.y)
				CGContextSaveGState(self.context.cgContext)
				CGContextConcatCTM(self.context.cgContext, RenderUtils.mapTransform(node.place))
				let shapes = renderer?.detectTouches(offsetLocation)
				CGContextRestoreGState(self.context.cgContext)
				self.selectedShape = shapes?.first
				if let shape = self.selectedShape {
					shape.onTap.onNext(TapEvent(location: Point(x: Double(offsetLocation.x), y: Double(offsetLocation.y))))
				}

			}
		}
	}

	func handlePan(recognizer: UIPanGestureRecognizer) {
		var translation = recognizer.translationInView(self)
		recognizer.setTranslation(CGPointZero, inView: self)
		if let shape = self.selectedShape {
			// get the rotation and scale of the shape and apply to the translation
			let transform = shape.place
			let rotation = -CGFloat(atan2f(Float(transform.m12), Float(transform.m11)))
			let scale = CGFloat(sqrt(transform.m11 * transform.m11 + transform.m21 * transform.m21))
			var translatedLocation = CGPointApplyAffineTransform(translation, CGAffineTransformMakeRotation(rotation))
			shape.onPan.onNext(PanEvent(dx: Double(translatedLocation.x / scale), dy: Double(translatedLocation.y / scale)))
		}
	}

	func handleRotation(recognizer: UIRotationGestureRecognizer) {
		let rotation = Double(recognizer.rotation)
		recognizer.rotation = 0
		if let shape = self.selectedShape {
			shape.onRotate.onNext(RotateEvent(angle: rotation))
		}
	}

	func handlePinch(recognizer: UIPinchGestureRecognizer) {
		let scale = Double(recognizer.scale)
		recognizer.scale = 1
		if let shape = self.selectedShape {
			shape.onPinch.onNext(PinchEvent(scale: scale))
		}
	}

	deinit {
		nodesMap.remove(node)
	}

}