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

			if let _ = superview {
				animationProducer.addStoredAnimations(node)
			}
		}
	}

	override public var frame: CGRect {
		didSet {
			super.frame = frame

			frameSetFirstTime = true

			guard let _ = superview else {
				return
			}

			animationProducer.addStoredAnimations(node)
		}
	}

	override public func didMoveToSuperview() {
		super.didMoveToSuperview()

		if !frameSetFirstTime {
			return

		}

		animationProducer.addStoredAnimations(node)
	}

	private var touched: Node? = nil

	var context: RenderContext!
	var renderer: NodeRenderer?

	var toRender = true
	var frameSetFirstTime = false

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
		renderer?.render(false, opacity: node.opacity)
	}

	public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.touched = nil
        for touch in touches {
            let location = touch.locationInView(self)
            self.touched = renderer!.findNodeAt(location)
            if let node = self.touched {
                let inverted = renderer!.node().place.invert()!
                let loc = CGPointApplyAffineTransform(location, RenderUtils.mapTransform(inverted))
                node.onTap.onNext(TapEvent(location: Point(x: Double(loc.x), y: Double(loc.y))))
            }
		}
	}

	func handlePan(recognizer: UIPanGestureRecognizer) {
		var translation = recognizer.translationInView(self)
		recognizer.setTranslation(CGPointZero, inView: self)
		if let node = self.touched {
			// get the rotation and scale of the shape and apply to the translation
			let transform = node.place
			let rotation = -CGFloat(atan2f(Float(transform.m12), Float(transform.m11)))
			let scale = CGFloat(sqrt(transform.m11 * transform.m11 + transform.m21 * transform.m21))
			var translatedLocation = CGPointApplyAffineTransform(translation, CGAffineTransformMakeRotation(rotation))
			node.onPan.onNext(PanEvent(dx: Double(translatedLocation.x / scale), dy: Double(translatedLocation.y / scale)))
		}
	}

	func handleRotation(recognizer: UIRotationGestureRecognizer) {
		let rotation = Double(recognizer.rotation)
		recognizer.rotation = 0
		if let node = self.touched {
			node.onRotate.onNext(RotateEvent(angle: rotation))
		}
	}

	func handlePinch(recognizer: UIPinchGestureRecognizer) {
		let scale = Double(recognizer.scale)
		recognizer.scale = 1
		if let node = self.touched {
			node.onPinch.onNext(PinchEvent(scale: scale))
		}
	}

	deinit {
		nodesMap.remove(node)
	}

}
