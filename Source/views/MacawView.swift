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
    
    private var selectedShape: Shape? = nil
    
	var context: RenderContext!
	var renderer: NodeRenderer?
    
	var animationProducer: AnimationProducer?
    
    var toRender = true

	public required init?(node: Node?, coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)

		self.context = RenderContext(view: self)
		self.node = node
		self.animationProducer = AnimationProducer(layer: self.layer)

		if let validNode = node {
			self.renderer = RenderUtils.createNodeRenderer(validNode, context: context)
		}
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MacawView.handlePan))
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(MacawView.handleRotation))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(MacawView.handlePinch))
        self.addGestureRecognizer(panRecognizer)
        self.addGestureRecognizer(rotationRecognizer)
        self.addGestureRecognizer(pinchRecognizer)
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
    
    public func handlePan(recognizer: UIPanGestureRecognizer) {
        // NOT WORKING YET
        var translation = recognizer.translationInView(self)
        recognizer.setTranslation(CGPointZero, inView: self)
        if let shape = self.selectedShape {
            var translatedLocation = CGPointApplyAffineTransform(translation, RenderUtils.mapTransform(shape.pos.invert()))
            if (translatedLocation.x == -translation.x) {
                return
            }
            // moving left, supposed to move right
            if Double(translatedLocation.x) > shape.pos.dx && translation.x < 0 {
                translation.x = translation.x * -1
            }
            translatedLocation = translation
            shape.onPan.onNext(PanEvent(dx: translatedLocation.x, dy: translatedLocation.y))

        }
        setNeedsDisplay()
    }
    
    public func handleRotation(recognizer: UIRotationGestureRecognizer) {
        let rotation = recognizer.rotation
        recognizer.rotation = 0
        if let shape = self.selectedShape {
            shape.onRotate.onNext(RotateEvent(radians: rotation))
        }
        setNeedsDisplay()
    }
    
    public func handlePinch(recognizer: UIPinchGestureRecognizer) {
        let scale = recognizer.scale
        recognizer.scale = 1
        if let shape = self.selectedShape {
            shape.onPinch.onNext(PinchEvent(scale: scale))
        }
        setNeedsDisplay()
    }
    
}
