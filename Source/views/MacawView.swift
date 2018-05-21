import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif
///
/// MacawView is a main class used to embed Macaw scene into your Cocoa UI.
/// You could create your own view extended from MacawView with predefined scene.
///
open class MacawView: MView, MGestureRecognizerDelegate {

    /// Scene root node
    open var node: Node = Group() {
        willSet {
            nodesMap.remove(node)
        }

        didSet {
            layoutHelper.nodeChanged()
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

    open var contentLayout: ContentLayout = .none {
        didSet {
            layoutHelper.layoutChanged()
            setNeedsDisplay()
        }
    }

    open override var contentMode: MViewContentMode {
        didSet {
            contentLayout = ContentLayout.of(contentMode: contentMode)
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

    private let layoutHelper = LayoutHelper()

    var touchesMap = [MTouchEvent: [Node]]()
    var touchesOfNode = [Node: [MTouchEvent]]()
    var recognizersMap = [MGestureRecognizer: [Node]]()

    var context: RenderContext!
    var renderer: NodeRenderer?

    var toRender = true
    var frameSetFirstTime = false

    internal var animationCache: AnimationCache?

    #if os(OSX)
    open override var layer: CALayer? {
        didSet {
            guard self.layer != nil else {
                return
            }
            initializeView()

            if let cache = self.animationCache {
                self.renderer = RenderUtils.createNodeRenderer(node, context: context, animationCache: cache)
            }
        }
    }
    #endif

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
        self.init(frame: frame)

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

    func initializeView() {
        self.contentLayout = .none
        self.context = RenderContext(view: self)

        guard let layer = self.mLayer else {
            return
        }

        self.animationCache = AnimationCache(sceneLayer: layer)

        let tapRecognizer = MTapGestureRecognizer(target: self, action: #selector(MacawView.handleTap))
        let longTapRecognizer = MLongPressGestureRecognizer(target: self, action: #selector(MacawView.handleLongTap(recognizer:)))
        let panRecognizer = MPanGestureRecognizer(target: self, action: #selector(MacawView.handlePan))
        let rotationRecognizer = MRotationGestureRecognizer(target: self, action: #selector(MacawView.handleRotation))
        let pinchRecognizer = MPinchGestureRecognizer(target: self, action: #selector(MacawView.handlePinch))

        tapRecognizer.delegate = self
        longTapRecognizer.delegate = self
        panRecognizer.delegate = self
        rotationRecognizer.delegate = self
        pinchRecognizer.delegate = self

        tapRecognizer.cancelsTouchesInView = false
        longTapRecognizer.cancelsTouchesInView = false
        panRecognizer.cancelsTouchesInView = false
        rotationRecognizer.cancelsTouchesInView = false
        pinchRecognizer.cancelsTouchesInView = false

        self.removeGestureRecognizers()
        self.addGestureRecognizer(tapRecognizer)
        self.addGestureRecognizer(longTapRecognizer)
        self.addGestureRecognizer(panRecognizer)
        self.addGestureRecognizer(rotationRecognizer)
        self.addGestureRecognizer(pinchRecognizer)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    override open func draw(_ rect: CGRect) {
        context.cgContext = MGraphicsGetCurrentContext()
        guard let ctx = context.cgContext else {
            return
        }

        if self.backgroundColor == nil {
            ctx.clear(rect)
        }

        guard let renderer = renderer else {
            return
        }
        ctx.concatenate(layoutHelper.getTransform(node, contentLayout, bounds.size.toMacaw()))
        renderer.render(force: false, opacity: node.opacity)
    }

    private func localContext( _ callback: (CGContext) -> Void) {
        MGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1.0)
        if let ctx = MGraphicsGetCurrentContext() {
            callback(ctx)
        }
        MGraphicsEndImageContext()
    }

    public final func findNodeAt(location: CGPoint) -> Node? {
        guard let ctx = context.cgContext else {
            return .none
        }
        return doFindNode(location: location, ctx: ctx)
    }

    private func doFindNode(location: CGPoint, ctx: CGContext) -> Node? {
        guard let renderer = renderer else {
            return .none
        }
        ctx.saveGState()
        defer {
            ctx.restoreGState()
        }
        let transform = layoutHelper.getTransform(node, contentLayout, bounds.size.toMacaw())
        ctx.concatenate(transform)
        let loc = location.applying(transform.inverted())
        return renderer.findNodeAt(location: loc, ctx: ctx)
    }

    // MARK: - Touches

    override func mTouchesBegan(_ touches: [MTouchEvent]) {

        if !self.node.shouldCheckForPressed() &&
            !self.node.shouldCheckForMoved() &&
            !self.node.shouldCheckForReleased () {
            return
        }

        guard let _ = renderer else {
            return
        }

        for touch in touches {
            let location = CGPoint(x: touch.x, y: touch.y)
            var foundNode: Node? = .none
            localContext { ctx in
                foundNode = doFindNode(location: location, ctx: ctx)
            }

            if let node = foundNode {
                if touchesMap[touch] == nil {
                    touchesMap[touch] = [Node]()
                }

                let inverted = node.place.invert()!
                let loc = location.applying(inverted.toCG())

                let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
                let point = TouchPoint(id: id, location: Point(x: Double(loc.x), y: Double(loc.y)))
                let touchEvent = TouchEvent(node: node, points: [point])

                var parent: Node? = node
                while parent != .none {
                    let currentNode = parent!
                    if touchesOfNode[currentNode] == nil {
                        touchesOfNode[currentNode] = [MTouchEvent]()
                    }

                    touchesMap[touch]?.append(currentNode)
                    touchesOfNode[currentNode]?.append(touch)
                    parent!.handleTouchPressed(touchEvent)

                    parent = nodesMap.parents(parent!).first
                }
            }
        }
    }

    override func mTouchesMoved(_ touches: [MTouchEvent]) {
        if !self.node.shouldCheckForMoved() {
            return
        }

        guard let _ = renderer else {
            return
        }

        touchesOfNode.keys.forEach { currentNode in
            guard let initialTouches = touchesOfNode[currentNode] else {
                return
            }

            var points = [TouchPoint]()
            for initialTouch in initialTouches {
                let currentIndex = touches.index(of: initialTouch)!
                let currentTouch = touches[currentIndex]
                let location = CGPoint(x: currentTouch.x, y: currentTouch.y)
                let inverted = currentNode.place.invert()!
                let loc = location.applying(inverted.toCG())
                let point = TouchPoint(id: currentTouch.id, location: Point(x: Double(loc.x), y: Double(loc.y)))
                points.append(point)
            }

            let touchEvent = TouchEvent(node: currentNode, points: points)
            currentNode.handleTouchMoved(touchEvent)
        }
    }

    override func mTouchesCancelled(_ touches: [MTouchEvent]) {
        touchesEnded(touches: touches)
    }

    override func mTouchesEnded(_ touches: [MTouchEvent]) {
        touchesEnded(touches: touches)
    }

    private func touchesEnded(touches: [MTouchEvent]) {
        guard let _ = renderer else {
            return
        }

        for touch in touches {

            touchesMap[touch]?.forEach { node in

                let inverted = node.place.invert()!
                let location = CGPoint(x: touch.x, y: touch.y)
                let loc = location.applying(inverted.toCG())
                let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
                let point = TouchPoint(id: id, location: Point(x: Double(loc.x), y: Double(loc.y)))
                let touchEvent = TouchEvent(node: node, points: [point])

                node.handleTouchReleased(touchEvent)
                if let index = touchesOfNode[node]?.index(of: touch) {
                    touchesOfNode[node]?.remove(at: index)
                    // swiftlint:disable empty_count
                    if let count = touchesOfNode[node]?.count, count == 0 {
                        touchesOfNode.removeValue(forKey: node)
                    }
                    // swiftlint:enable empty_count
                }
            }

            touchesMap.removeValue(forKey: touch)
        }
    }

    // MARK: - Tap

    @objc func handleTap(recognizer: MTapGestureRecognizer) {
        if !self.node.shouldCheckForTap() {
            return
        }

        guard let _ = renderer else {
            return
        }

        let location = recognizer.location(in: self)
        var foundNodes = [Node]()

        localContext { ctx in
            guard let foundNode = doFindNode(location: location, ctx: ctx) else {
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
            let loc = location.applying(inverted.toCG())
            let event = TapEvent(node: node, location: Point(x: Double(loc.x), y: Double(loc.y)))
            node.handleTap(event)
        }
    }

    // MARK: - Tap

    @objc func handleLongTap(recognizer: MLongPressGestureRecognizer) {
        if !self.node.shouldCheckForLongTap() {
            return
        }

        guard let _ = renderer else {
            return
        }

        let location = recognizer.location(in: self)
        var foundNodes = [Node]()

        localContext { ctx in
            guard let foundNode = doFindNode(location: location, ctx: ctx) else {
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
            let loc = location.applying(inverted.toCG())
            let event = TapEvent(node: node, location: Point(x: Double(loc.x), y: Double(loc.y)))
            node.handleLongTap(event, touchBegan: recognizer.state == .began)
        }
    }

    // MARK: - Pan

    @objc func handlePan(recognizer: MPanGestureRecognizer) {
        if !self.node.shouldCheckForPan() {
            return
        }

        guard let _ = renderer else {
            return
        }

        if recognizer.state == .began {
            let location = recognizer.location(in: self)

            localContext { ctx in
                guard let foundNode = doFindNode(location: location, ctx: ctx) else {
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
                                 count: recognizer.mNumberOfTouches())
            node.handlePan(event)
        }

        if recognizer.state == .ended || recognizer.state == .cancelled {
            recognizersMap.removeValue(forKey: recognizer)
        }
    }

    // MARK: - Rotation

    @objc func handleRotation(_ recognizer: MRotationGestureRecognizer) {
        if !self.node.shouldCheckForRotate() {
            return
        }

        guard let _ = renderer else {
            return
        }

        if recognizer.state == .began {
            let location = recognizer.location(in: self)

            localContext { ctx in
                guard let foundNode = doFindNode(location: location, ctx: ctx) else {
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

    @objc func handlePinch(_ recognizer: MPinchGestureRecognizer) {
        if !self.node.shouldCheckForPinch() {
            return
        }

        guard let _ = renderer else {
            return
        }

        if recognizer.state == .began {
            let location = recognizer.location(in: self)

            localContext { ctx in
                guard let foundNode = doFindNode(location: location, ctx: ctx) else {
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

        let scale = Double(recognizer.mScale)
        recognizer.mScale = 1

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

    // MARK: - MGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: MGestureRecognizer, shouldReceive touch: MTouch) -> Bool {
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: MGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: MGestureRecognizer) -> Bool {
        return true
    }
}

private class LayoutHelper {

    private var prevSize: Size?
    private var prevRect: Rect?
    private var prevTransform: CGAffineTransform?

    public func getTransform(_ node: Node, _ layout: ContentLayout, _ size: Size) -> CGAffineTransform {
        setSize(size: size)
        if let rect = getNodeBounds(node: node) {
            setRect(rect: rect)
            if let transform = prevTransform {
                return transform
            }
            return setTransform(transform: layout.layout(rect: prevRect!, into: size).toCG())
        }
        return CGAffineTransform.identity
    }

    public func nodeChanged() {
        prevRect = nil
    }

    public func layoutChanged() {
        prevTransform = nil
    }

    private func getNodeBounds(node: Node) -> Rect? {
        if let canvas = node as? SVGCanvas {
            if let rect = prevRect {
                return rect
            }
            return canvas.layout(size: prevSize!).rect()
        } else {
            return node.bounds()
        }
    }

    private func setSize(size: Size) {
        if let prevSize = prevSize {
            if prevSize == size {
                return
            }
        }
        prevSize = size
        prevRect = nil
        prevTransform = nil
    }

    private func setRect(rect: Rect) {
        if let prevRect = prevRect {
            if prevRect == rect {
                return
            }
        }
        prevRect = rect
        prevTransform = nil
    }

    private func setTransform(transform: CGAffineTransform) -> CGAffineTransform {
        prevTransform = transform
        return transform
    }

}
