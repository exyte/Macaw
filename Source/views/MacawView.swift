import Foundation
import UIKit

///
/// MacawView is a main class used to embed Macaw scene into your Cocoa UI.
/// You could create your own view extended from MacawView with predefined scene.
///
open class MacawView: UIView {
    
    /// Scene root node
    open var node: Node = Group() {
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
            
            self.setNeedsDisplay()
        }
    }
    
    override open var frame: CGRect {
        didSet {
            super.frame = frame
            
            frameSetFirstTime = true
            
            guard let _ = superview else {
                return
            }
            
            animationProducer.addStoredAnimations(node)
        }
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if !frameSetFirstTime {
            return
            
        }
        
        animationProducer.addStoredAnimations(node)
    }
    
    var touchesMap = [UITouch: Node]()
    var recognizersMap = [UIGestureRecognizer: Node]()
    
    var context: RenderContext!
    var renderer: NodeRenderer?
    
    var toRender = true
    var frameSetFirstTime = false
    
    internal var animationCache: AnimationCache?
    
    public init?(node: Node, coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        initializeView()
        
        self.node = node
        nodesMap.add(node, view: self)
        if let cache = self.animationCache {
            self.renderer = RenderUtils.createNodeRenderer(node, context: context, animationCache: cache)
        }
    }
    
    public convenience init(node: Node, frame: CGRect) {
        self.init(frame:frame)
        
        self.node = node
        nodesMap.add(node, view: self)
        if let cache = self.animationCache {
            self.renderer = RenderUtils.createNodeRenderer(node, context: context, animationCache: cache)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeView()
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(node: Group(), coder: aDecoder)
    }
    
    fileprivate func initializeView() {
        self.context = RenderContext(view: self)
        self.animationCache = AnimationCache(sceneLayer: self.layer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MacawView.handlePan))
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(MacawView.handleRotation))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(MacawView.handlePinch))
        self.addGestureRecognizer(panRecognizer)
        self.addGestureRecognizer(rotationRecognizer)
        self.addGestureRecognizer(pinchRecognizer)
    }
    
    override open func draw(_ rect: CGRect) {
        self.context.cgContext = UIGraphicsGetCurrentContext()
        renderer?.render(force: false, opacity: node.opacity)
    }
    
    private func localContext( _ callback: (CGContext) -> ()) {
        UIGraphicsBeginImageContext(self.bounds.size)
        if let ctx = UIGraphicsGetCurrentContext() {
            callback(ctx)
        }
        UIGraphicsEndImageContext()
    }
    
    // MARK: - Touches
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !self.node.shouldCheckForPressed() {
            return
        }
        
        guard let renderer = renderer else {
            return
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            var foundNode: Node? = .none
            localContext { ctx in
                foundNode = renderer.findNodeAt(location: location, ctx: ctx)
            }
            
            if let node = foundNode {
                let inverted = renderer.node().place.invert()!
                let loc = location.applying(RenderUtils.mapTransform(inverted))
                let touchEvent = TouchEvent(node: node, point: TouchPoint(id: Int(touch.timestamp), location: Point(x: Double(loc.x), y: Double(loc.y))))
                
                var parent: Node? = node
                while parent != .none {
                    
                    if parent!.shouldCheckForPressed() {
                        touchesMap[touch] = parent!
                        parent!.handleTouchPressed(touchEvent)
                    }

                    if (touchEvent.consumed) {
                        break;
                    }
                    
                    parent = nodesMap.parents(parent!).first
                }
            }
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !self.node.shouldCheckForMoved() {
            return
        }
        
        guard let renderer = renderer else {
            return
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if let node = touchesMap[touch] {
                let inverted = renderer.node().place.invert()!
                let loc = location.applying(RenderUtils.mapTransform(inverted))
                let touchEvent = TouchEvent(node: node, point: TouchPoint(id: Int(touch.timestamp), location: Point(x: Double(loc.x), y: Double(loc.y))))
                    node.handleTouchMoved(touchEvent)
            }
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches: touches, event: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches: touches, event: event)
    }
    
    private func touchesEnded(touches: Set<UITouch>, event: UIEvent?) {
        if !self.node.shouldCheckForReleased() {
            return
        }
        
        guard let renderer = renderer else {
            return
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if let node = touchesMap[touch] {
                let inverted = renderer.node().place.invert()!
                let loc = location.applying(RenderUtils.mapTransform(inverted))
                let touchEvent = TouchEvent(node: node, point: TouchPoint(id: Int(touch.timestamp), location: Point(x: Double(loc.x), y: Double(loc.y))))
                
                
                node.handleTouchReleased(touchEvent)
                touchesMap.removeValue(forKey: touch)
            }
        }
    }
    
    
    // MARK: - Pan
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if !self.node.shouldCheckForPan() {
            return
        }
        
        guard let renderer = renderer else {
            return
        }
        
        if recognizer.state == .began {
            let location = recognizer.location(in: self)
            

            localContext { ctx in
                guard let foundNode = renderer.findNodeAt(location: location, ctx: ctx) else {
                    return
                }
                
                var parent: Node? = node
                while parent != .none {
                    if parent!.shouldCheckForPan() {
                       self.recognizersMap[recognizer] = parent!
                        break;
                    }

                    parent = nodesMap.parents(parent!).first
                }
            }
        }

        if let node = recognizersMap[recognizer] {
            // get the rotation and scale of the shape and apply to the translation
            let translation = recognizer.translation(in: self)
            recognizer.setTranslation(CGPoint.zero, in: self)
            
            let transform = node.place
            let rotation = -CGFloat(atan2f(Float(transform.m12), Float(transform.m11)))
            let scale = CGFloat(sqrt(transform.m11 * transform.m11 + transform.m21 * transform.m21))
            let translatedLocation = translation.applying(CGAffineTransform(rotationAngle: rotation))
            let event = PanEvent(node: node, dx: Double(translatedLocation.x / scale), dy: Double(translatedLocation.y / scale),
                                 count: recognizer.numberOfTouches)
            node.handlePan(event)
        }
        
        if recognizer.state == .ended || recognizer.state == .cancelled {
            recognizersMap.removeValue(forKey: recognizer)
        }
    }
    
    // MARK: - Rotation
    
    func handleRotation(_ recognizer: UIRotationGestureRecognizer) {
        if !self.node.shouldCheckForRotate() {
            return
        }
        
        guard let renderer = renderer else {
            return
        }
        
        if recognizer.state == .began {
            let location = recognizer.location(in: self)
            
            
            localContext { ctx in
                guard let foundNode = renderer.findNodeAt(location: location, ctx: ctx) else {
                    return
                }
                
                var parent: Node? = node
                while parent != .none {
                    if parent!.shouldCheckForRotate() {
                        self.recognizersMap[recognizer] = parent!
                        break;
                    }
                    
                    parent = nodesMap.parents(parent!).first
                }
            }
        }

        if let node = recognizersMap[recognizer] {
            let rotation = Double(recognizer.rotation)
            recognizer.rotation = 0
            
            let event = RotateEvent(node: node, angle: rotation)
            node.handleRotate(event)
        }
        
        if recognizer.state == .ended || recognizer.state == .cancelled {
            recognizersMap.removeValue(forKey: recognizer)
        }
    }
    
    // MARK: - Pinch
    
    func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        if !self.node.shouldCheckForPinch() {
            return
        }
        
        guard let renderer = renderer else {
            return
        }
        
        if recognizer.state == .began {
            let location = recognizer.location(in: self)
            
            
            localContext { ctx in
                guard let foundNode = renderer.findNodeAt(location: location, ctx: ctx) else {
                    return
                }
                
                var parent: Node? = node
                while parent != .none {
                    if parent!.shouldCheckForPinch() {
                        self.recognizersMap[recognizer] = parent!
                        break;
                    }
                    
                    parent = nodesMap.parents(parent!).first
                }
            }
        }
        
        if let node = recognizersMap[recognizer] {
            let scale = Double(recognizer.scale)
            recognizer.scale = 1
            
            let event = PinchEvent(node: node, scale: scale)
            node.handlePinch(event)
        }
        
        if recognizer.state == .ended || recognizer.state == .cancelled {
            recognizersMap.removeValue(forKey: recognizer)
        }
    }
    
    deinit {
        nodesMap.remove(node)
    }
    
}
