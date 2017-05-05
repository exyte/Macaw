import Foundation
import UIKit

///
/// MacawView is a main class used to embed Macaw scene into your Cocoa UI.
/// You could create your own view extended from MacawView with predefined scene.
///
open class MacawView: UIView, UIGestureRecognizerDelegate {
    
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
    
    var touchesMap = [UITouch: [Node]]()
    var touchesOfNode = [Node: [UITouch]]()
    var recognizersMap = [UIGestureRecognizer: [Node]]()
    
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MacawView.handleTap))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MacawView.handlePan))
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(MacawView.handleRotation))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(MacawView.handlePinch))
        
        tapRecognizer.delegate = self
        panRecognizer.delegate = self
        rotationRecognizer.delegate = self
        pinchRecognizer.delegate = self
        
        tapRecognizer.cancelsTouchesInView = false
        panRecognizer.cancelsTouchesInView = false
        rotationRecognizer.cancelsTouchesInView = false
        pinchRecognizer.cancelsTouchesInView = false
        
        self.addGestureRecognizer(tapRecognizer)
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
        
        if !self.node.shouldCheckForPressed() &&
            !self.node.shouldCheckForMoved() &&
            !self.node.shouldCheckForReleased (){
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
                if touchesMap[touch] == nil {
                    touchesMap[touch] = [Node]()
                }
                
                let inverted = node.place.invert()!
                let loc = location.applying(RenderUtils.mapTransform(inverted))
                
                let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
                let point = TouchPoint(id: id, location: Point(x: Double(loc.x), y: Double(loc.y)))
                let touchEvent = TouchEvent(node: node, points: [point])
                
                var parent: Node? = node
                while parent != .none {
                    let currentNode = parent!
                    if touchesOfNode[currentNode] == nil {
                        touchesOfNode[currentNode] = [UITouch]()
                    }
                    
                    touchesMap[touch]?.append(currentNode)
                    touchesOfNode[currentNode]?.append(touch)
                    parent!.handleTouchPressed(touchEvent)
                    

                    parent = nodesMap.parents(parent!).first
                }
            }
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !self.node.shouldCheckForMoved() {
            return
        }
        
        guard let _ = renderer else {
            return
        }
        
        touchesOfNode.keys.forEach { currentNode in
            guard let touches = touchesOfNode[currentNode] else {
                return
            }
            
            var points = [TouchPoint]()
            for touch in touches {
                let location = touch.location(in: self)
                let inverted = currentNode.place.invert()!
                let loc = location.applying(RenderUtils.mapTransform(inverted))
                let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
                let point = TouchPoint(id: id, location: Point(x: Double(loc.x), y: Double(loc.y)))
                points.append(point)
            }
            
            let touchEvent = TouchEvent(node: currentNode, points: points)
            currentNode.handleTouchMoved(touchEvent)
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches: touches, event: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches: touches, event: event)
    }
    
    private func touchesEnded(touches: Set<UITouch>, event: UIEvent?) {

        
        guard let _ = renderer else {
            return
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            touchesMap[touch]?.forEach { node in
                
                let inverted = node.place.invert()!
                let loc = location.applying(RenderUtils.mapTransform(inverted))
                let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
                let point = TouchPoint(id: id, location: Point(x: Double(loc.x), y: Double(loc.y)))
                let touchEvent = TouchEvent(node: node, points: [point])
                
                node.handleTouchReleased(touchEvent)
                if let index = touchesOfNode[node]?.index(of: touch) {
                    touchesOfNode[node]?.remove(at: index)
                    if let count = touchesOfNode[node]?.count, count == 0 {
                        touchesOfNode.removeValue(forKey: node)
                    }
                }
            }
            
            touchesMap.removeValue(forKey: touch)
        }
    }
    
    
    // MARK: - Pan
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        if !self.node.shouldCheckForTap() {
            return
        }
        
        guard let renderer = renderer else {
            return
        }
        
        let location = recognizer.location(in: self)
        var foundNodes = [Node]()
        
        localContext { ctx in
            guard let foundNode = renderer.findNodeAt(location: location, ctx: ctx) else {
                return
            }
            
            var parent: Node? = foundNode
            while parent != .none {
                if parent!.shouldCheckForTap() {
                    foundNodes.append(parent!)
                }
                
                parent = nodesMap.parents(parent!).first
            }
        }
        
        
        foundNodes.forEach { node in
            let inverted = node.place.invert()!
            let loc = location.applying(RenderUtils.mapTransform(inverted))
            let event = TapEvent(node: node, location: Point(x: Double(loc.x), y: Double(loc.y)))
            node.handleTap(event)
        }
    }
    
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
                
                if self.recognizersMap[recognizer] == nil {
                    self.recognizersMap[recognizer] = [Node]()
                }

                var parent: Node? = foundNode
                while parent != .none {
                    if parent!.shouldCheckForPan() {
                       self.recognizersMap[recognizer]?.append(parent!)
                    }

                    parent = nodesMap.parents(parent!).first
                }
            }
        }
        
        // get the rotation and scale of the shape and apply to the translation
        let translation = recognizer.translation(in: self)
        recognizer.setTranslation(CGPoint.zero, in: self)
        
        let transform = node.place
        let rotation = -CGFloat(atan2f(Float(transform.m12), Float(transform.m11)))
        let scale = CGFloat(sqrt(transform.m11 * transform.m11 + transform.m21 * transform.m21))
        let translatedLocation = translation.applying(CGAffineTransform(rotationAngle: rotation))
        
        recognizersMap[recognizer]?.forEach { node in
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
                
                if self.recognizersMap[recognizer] == nil {
                    self.recognizersMap[recognizer] = [Node]()
                }
                
                var parent: Node? = foundNode
                while parent != .none {
                    if parent!.shouldCheckForRotate() {
                        self.recognizersMap[recognizer]?.append(parent!)
                    }
                    
                    parent = nodesMap.parents(parent!).first
                }
            }
        }
        
        let rotation = Double(recognizer.rotation)
        recognizer.rotation = 0
        
        recognizersMap[recognizer]?.forEach { node in
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
                
                if self.recognizersMap[recognizer] == nil {
                    self.recognizersMap[recognizer] = [Node]()
                }
                
                var parent: Node? = foundNode
                while parent != .none {
                    if parent!.shouldCheckForPinch() {
                        self.recognizersMap[recognizer]?.append(parent!)
                    }
                    
                    parent = nodesMap.parents(parent!).first
                }
            }
        }
        
        let scale = Double(recognizer.scale)
        recognizer.scale = 1
        
        recognizersMap[recognizer]?.forEach { node in
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
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
