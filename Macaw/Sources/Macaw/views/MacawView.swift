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
        didSet {
            layoutHelper.nodeChanged()
            self.renderer?.dispose()
            self.renderer = RenderUtils.createNodeRenderer(node, view: self)

            if let _ = superview {
                animationProducer.addStoredAnimations(node, self)
            }

            self.setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }

    open var contentLayout: ContentLayout = .none {
        didSet {
            layoutHelper.layoutChanged()
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }

    open override var contentMode: MViewContentMode {
        didSet {
            contentLayout = ContentLayout.of(contentMode: contentMode)
        }
    }

    public let zoom = MacawZoom()

    public var place: Transform {
        return placeManager.placeVar.value
    }

    public var placeVar: Variable<Transform> {
        return placeManager.placeVar
    }

    private let placeManager = RootPlaceManager()

    override open var frame: CGRect {
        didSet {
            super.frame = frame

            frameSetFirstTime = true

            guard let _ = superview else {
                return
            }

            animationProducer.addStoredAnimations(node, self)
        }
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()

        if !frameSetFirstTime {
            return
        }

        animationProducer.addStoredAnimations(node, self)
    }

    override open var intrinsicContentSize: CGSize {
        if let bounds = node.bounds {
            return bounds.size().toCG()
        } else {
            return CGSize(width: MNoIntrinsicMetric(), height: MNoIntrinsicMetric())
        }
    }

    private let layoutHelper = LayoutHelper()

    var touchesMap = [MTouchEvent: [NodePath]]()
    var touchesOfNode = [Node: [MTouchEvent]]()
    var recognizersMap = [MGestureRecognizer: [Node]]()

    var context: RenderContext!
    var renderer: NodeRenderer?

    var toRender = true
    var frameSetFirstTime = false

    #if os(OSX)
    open override var layer: CALayer? {
        didSet {
            guard self.layer != nil else {
                return
            }
            initializeView()

            self.renderer = RenderUtils.createNodeRenderer(node, view: self)
        }
    }
    #endif

    @objc public init?(node: Node, coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        zoom.initialize(view: self, onChange: onZoomChange)

        initializeView()

        self.node = node
        self.renderer = RenderUtils.createNodeRenderer(node, view: self)
        backgroundColor = .white
    }

    public convenience init(node: Node, frame: CGRect) {
        self.init(frame: frame)

        self.node = node
        self.renderer = RenderUtils.createNodeRenderer(node, view: self)
        backgroundColor = .white
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        zoom.initialize(view: self, onChange: onZoomChange)

        initializeView()
    }

    @objc public convenience required init?(coder aDecoder: NSCoder) {
        self.init(node: Group(), coder: aDecoder)
    }

    private func onZoomChange(t: Transform) {
        placeManager.setZoom(place: t)
        self.setNeedsDisplay()
    }

    func initializeView() {
        self.contentLayout = .none
        self.context = RenderContext(view: self)

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
        renderer.calculateZPositionRecursively()

        // TODO: actually we should track all changes
        placeManager.setLayout(place: layoutHelper.getTransform(renderer, contentLayout, bounds.size.toMacaw()))

        ctx.concatenate(self.place.toCG())
        renderer.render(in: ctx, force: false, opacity: node.opacity)
    }

    public final func findNodeAt(location: CGPoint) -> Node? {
        guard let ctx = context.cgContext else {
            return .none
        }
        return doFindNode(location: location, ctx: ctx)?.node
    }

    private func doFindNode(location: CGPoint, ctx: CGContext) -> NodePath? {
        guard let renderer = renderer else {
            return .none
        }
        return renderer.findNodeAt(location: location, ctx: ctx)
    }

    private func doFindNode(location: CGPoint) -> NodePath? {
        MGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1.0)
        defer {
            MGraphicsEndImageContext()
        }
        guard let ctx = MGraphicsGetCurrentContext() else {
            return .none
        }
        return doFindNode(location: location, ctx: ctx)
    }

    // MARK: - Touches
    override func mTouchesBegan(_ touches: Set<MTouch>, with event: MEvent?) {
        zoom.touchesBegan(touches)

        let touchPoints = convert(touches: touches)
        if !self.node.shouldCheckForPressed() &&
            !self.node.shouldCheckForMoved() &&
            !self.node.shouldCheckForReleased () {
            return
        }

        guard let _ = renderer else {
            return
        }

        for touch in touchPoints {
            let location = CGPoint(x: touch.x, y: touch.y)
            var nodePath = doFindNode(location: location)

            if touchesMap[touch] == nil {
                touchesMap[touch] = [NodePath]()
            }

            let inverted = node.place.invert()!
            let loc = location.applying(inverted.toCG())

            var relativeToView = CGPoint.zero
            if let invertedViewPlace = self.place.invert() {
                relativeToView = location.applying(invertedViewPlace.toCG())
            }

            let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())

            while let current = nodePath {
                let node = current.node
                let relativeLocation = current.location
                let point = TouchPoint(id: id, location: loc.toMacaw(), relativeToNodeLocation: relativeLocation.toMacaw(), relativeToViewLocation: relativeToView.toMacaw())
                let touchEvent = TouchEvent(node: node, points: [point])

                if touchesOfNode[node] == nil {
                    touchesOfNode[node] = [MTouchEvent]()
                }

                touchesMap[touch]?.append(current)
                touchesOfNode[node]?.append(touch)
                node.handleTouchPressed(touchEvent)

                nodePath = current.parent
            }
        }
    }

    override func mTouchesMoved(_ touches: Set<MTouch>, with event: MEvent?) {
        zoom.touchesMoved(touches)
        if !self.node.shouldCheckForMoved() {
            return
        }

        guard let _ = renderer else {
            return
        }

        let touchPoints = convert(touches: touches)
        touchesOfNode.keys.forEach { currentNode in
            guard let initialTouches = touchesOfNode[currentNode] else {
                return
            }

            let invertedViewPlace = self.place.invert()
            var points = [TouchPoint]()
            for initialTouch in initialTouches {
                guard let currentIndex = touchPoints.firstIndex(of: initialTouch) else {
                    continue
                }
                let currentTouch = touchPoints[currentIndex]
                guard let nodePath = touchesMap[currentTouch]?.first else {
                    continue
                }
                let location = CGPoint(x: currentTouch.x, y: currentTouch.y)
                let inverted = currentNode.place.invert()!
                let loc = location.applying(inverted.toCG())

                var relativeToView = CGPoint.zero
                if let invertedViewPlace = invertedViewPlace {
                    relativeToView = location.applying(invertedViewPlace.toCG())
                }

                let point = TouchPoint(id: currentTouch.id, location: loc.toMacaw(), relativeToNodeLocation: nodePath.location.toMacaw(), relativeToViewLocation: relativeToView.toMacaw())
                points.append(point)
            }

            let touchEvent = TouchEvent(node: currentNode, points: points)
            currentNode.handleTouchMoved(touchEvent)
        }
    }

    override func mTouchesCancelled(_ touches: Set<MTouch>, with event: MEvent?) {
        touchesEnded(touches: touches)
    }

    override func mTouchesEnded(_ touches: Set<MTouch>, with event: MEvent?) {
        touchesEnded(touches: touches)
    }

    private func convert(touches: Set<MTouch>) -> [MTouchEvent] {
        return touches.map { touch -> MTouchEvent in
            let location = touch.location(in: self)
            let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
            return MTouchEvent(x: Double(location.x), y: Double(location.y), id: id)
        }
    }

    private func touchesEnded(touches: Set<MTouch>) {
        zoom.touchesEnded(touches)
        guard let _ = renderer else {
            return
        }

        let invertedViewPlace = self.place.invert()
        let touchPoints = convert(touches: touches)
        for touch in touchPoints {

            touchesMap[touch]?.forEach { nodePath in

                let node = nodePath.node
                let inverted = node.place.invert()!
                let location = CGPoint(x: touch.x, y: touch.y)
                let loc = location.applying(inverted.toCG())

                var relativeToView = CGPoint.zero
                if let invertedViewPlace = invertedViewPlace {
                    relativeToView = location.applying(invertedViewPlace.toCG())
                }

                let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
                let point = TouchPoint(id: id, location: loc.toMacaw(), relativeToNodeLocation: nodePath.location.toMacaw(), relativeToViewLocation: relativeToView.toMacaw())
                let touchEvent = TouchEvent(node: node, points: [point])

                node.handleTouchReleased(touchEvent)
                if let index = touchesOfNode[node]?.firstIndex(of: touch) {
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
        var nodePath = doFindNode(location: location)

        while let current = nodePath {
            let node = current.node
            let inverted = node.place.invert()!
            let loc = location.applying(inverted.toCG())
            let event = TapEvent(node: node, location: loc.toMacaw())
            node.handleTap(event)
            nodePath = nodePath?.parent
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
        guard var nodePath = doFindNode(location: location) else {
            return
        }

        while let next = nodePath.parent {
            let node = nodePath.node
            let inverted = node.place.invert()!
            let loc = location.applying(inverted.toCG())
            let event = TapEvent(node: node, location: loc.toMacaw())
            node.handleLongTap(event, touchBegan: recognizer.state == .began)
            nodePath = next
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
            guard var nodePath = doFindNode(location: location) else {
                return
            }

            if self.recognizersMap[recognizer] == nil {
                self.recognizersMap[recognizer] = [Node]()
            }

            while let next = nodePath.parent {
                let node = nodePath.node
                if node.shouldCheckForPan() {
                    self.recognizersMap[recognizer]?.append(node)
                }
                nodePath = next
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
            guard var nodePath = doFindNode(location: location) else {
                return
            }

            if self.recognizersMap[recognizer] == nil {
                self.recognizersMap[recognizer] = [Node]()
            }

            while let next = nodePath.parent {
                let node = nodePath.node
                if node.shouldCheckForRotate() {
                    self.recognizersMap[recognizer]?.append(node)
                }
                nodePath = next
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
            guard var nodePath = doFindNode(location: location) else {
                return
            }

            if self.recognizersMap[recognizer] == nil {
                self.recognizersMap[recognizer] = [Node]()
            }

            while let next = nodePath.parent {
                let node = nodePath.node
                if node.shouldCheckForPinch() {
                    self.recognizersMap[recognizer]?.append(node)
                }
                nodePath = next
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

    // MARK: - MGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: MGestureRecognizer, shouldReceive touch: MTouch) -> Bool {
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: MGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: MGestureRecognizer) -> Bool {
        return true
    }
}

class LayoutHelper {

    private var prevSize: Size?
    private var prevRect: Rect?
    private var prevTransform: Transform?

    public func getTransform(_ nodeRenderer: NodeRenderer, _ layout: ContentLayout, _ size: Size) -> Transform {
        setSize(size: size)
        let node = nodeRenderer.node
        var rect = node.bounds
        if let canvas = node as? SVGCanvas {
            if let view = nodeRenderer.view {
                rect = canvas.layout(size: view.bounds.size.toMacaw()).rect()
            } else {
                rect = BoundsUtils.getNodesBounds(canvas.contents)
            }
        }

        if let rect = rect {
            setRect(rect: rect)
            if let transform = prevTransform {
                return transform
            }
            return setTransform(transform: layout.layout(rect: rect, into: size))
        }
        return Transform.identity
    }

    public class func calcTransform(_ node: Node, _ layout: ContentLayout, _ size: Size) -> Transform {
        if layout is NoneLayout {
            return Transform.identity
        }
        if let canvas = node as? SVGCanvas {
            return layout.layout(size: canvas.layout(size: size), into: size)
        }
        if let rect = node.bounds {
            return layout.layout(rect: rect, into: size)
        }
        return Transform.identity
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
            return node.bounds
        }
    }

    private func setSize(size: Size) {
        if let prevSize = prevSize, prevSize == size {
            return
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

    private func setTransform(transform: Transform) -> Transform {
        prevTransform = transform
        return transform
    }

}

class RootPlaceManager {

    var placeVar = Variable(Transform.identity)
    private var places: [Transform] = [.identity, .identity]

    func setLayout(place: Transform) {
        if places[1] !== place {
            places[1] = place
            placeVar.value = recalc()
        }
    }

    func setZoom(place: Transform) {
        if places[0] !== place {
            places[0] = place
            placeVar.value = recalc()
        }
    }

    private func recalc() -> Transform {
        if places[0] === Transform.identity {
            return places[1]
        } else if places[1] === Transform.identity {
            return places[0]
        }
        return places[0].concat(with: places[1])
    }

}
