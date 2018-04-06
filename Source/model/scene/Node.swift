import Foundation

open class Node: Drawable {

    open let placeVar: AnimatableVariable<Transform>
    open var place: Transform {
        get { return placeVar.value }
        set(val) { placeVar.value = val }
    }

    open let opaqueVar: Variable<Bool>
    open var opaque: Bool {
        get { return opaqueVar.value }
        set(val) { opaqueVar.value = val }
    }

    open let opacityVar: AnimatableVariable<Double>
    open var opacity: Double {
        get { return opacityVar.value }
        set(val) { opacityVar.value = val }
    }

    open let clipVar: Variable<Locus?>
    open var clip: Locus? {
        get { return clipVar.value }
        set(val) { clipVar.value = val }
    }

    open let effectVar: Variable<Effect?>
    open var effect: Effect? {
        get { return effectVar.value }
        set(val) { effectVar.value = val }
    }

    open var attributes: [String: String]

    internal var id: String {
        didSet {
            Node.map.removeObject(forKey: id as NSString)
            Node.map.setObject(self, forKey: id as NSString)
        }
    }

    // MARK: - ID map
    private static let map = NSMapTable<NSString, Node>(keyOptions: NSMapTableStrongMemory, valueOptions: NSMapTableWeakMemory)

    open static func nodeBy(id: String) -> Node? {
        return Node.map.object(forKey: id as NSString)
    }

    // MARK: - Searching
    public func nodeBy(tag: String) -> Node? {
        if self.tag.contains(tag) {
            return self
        }

        return .none
    }

    public func nodesBy(tag: String) -> [Node] {
        return [nodeBy(tag: tag)].flatMap { $0 }
    }

    // MARK: - Events

    var touchPressedHandlers = [ChangeHandler<TouchEvent>]()
    var touchMovedHandlers = [ChangeHandler<TouchEvent>]()
    var touchReleasedHandlers = [ChangeHandler<TouchEvent>]()

    var prevTouchCount: Int = 0
    var prevTouchTimer: Timer?
    var isLongTapInProgress = false

    var tapHandlers = [Int: [ChangeHandler<TapEvent>]]()
    var longTapHandlers = [ChangeHandler<TapEvent>]()
    var panHandlers = [ChangeHandler<PanEvent>]()
    var rotateHandlers = [ChangeHandler<RotateEvent>]()
    var pinchHandlers = [ChangeHandler<PinchEvent>]()

    @discardableResult public func onTouchPressed (_ f: @escaping (TouchEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<TouchEvent>(f)
        touchPressedHandlers.append(handler)

        return Disposable { [weak self]  in
            guard let index = self?.touchPressedHandlers.index(of: handler) else {
                return
            }

            self?.touchPressedHandlers.remove(at: index)
        }
    }

    @discardableResult public func onTouchMoved   (_ f: @escaping (TouchEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<TouchEvent>(f)
        touchMovedHandlers.append(handler)

        return Disposable { [weak self] in
            guard let index = self?.touchMovedHandlers.index(of: handler) else {
                return
            }

            self?.touchMovedHandlers.remove(at: index)
        }
    }

    @discardableResult public func onTouchReleased(_ f: @escaping (TouchEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<TouchEvent>(f)
        touchReleasedHandlers.append(handler)

        return Disposable { [weak self] in
            guard let index = self?.touchReleasedHandlers.index(of: handler) else {
                return
            }

            self?.touchReleasedHandlers.remove(at: index)
        }
    }

    @discardableResult public func onTap(tapCount: Int = 1, f: @escaping (TapEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<TapEvent>(f)
        if var handlers = tapHandlers[tapCount] {
            handlers.append(handler)
        } else {
            tapHandlers[tapCount] = [handler]
        }

        return Disposable { [weak self]  in
            guard let index = self?.tapHandlers[tapCount]?.index(of: handler) else {
                return
            }

            self?.tapHandlers[tapCount]?.remove(at: index)
        }
    }

    @discardableResult public func onLongTap(_ f: @escaping (TapEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<TapEvent>(f)
        longTapHandlers.append(handler)

        return Disposable { [weak self] in
            guard let index = self?.longTapHandlers.index(of: handler) else {
                return
            }

            self?.longTapHandlers.remove(at: index)
        }
    }

    @discardableResult public func onPan(_ f: @escaping (PanEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<PanEvent>(f)
        panHandlers.append(handler)

        return Disposable { [weak self] in
            guard let index = self?.panHandlers.index(of: handler) else {
                return
            }

            self?.panHandlers.remove(at: index)
        }
    }

    @discardableResult public func onRotate(_ f: @escaping (RotateEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<RotateEvent>(f)
        rotateHandlers.append(handler)

        return Disposable { [weak self] in
            guard let index = self?.rotateHandlers.index(of: handler) else {
                return
            }

            self?.rotateHandlers.remove(at: index)
        }
    }

    @discardableResult public func onPinch(_ f: @escaping (PinchEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<PinchEvent>(f)
        pinchHandlers.append(handler)

        return Disposable { [weak self] in
            guard let index = self?.pinchHandlers.index(of: handler) else {
                return
            }

            self?.pinchHandlers.remove(at: index)
        }
    }

    // Helpers

    func handleTouchPressed(_ event: TouchEvent) {
        touchPressedHandlers.forEach { handler in handler.handle(event) }
    }

    func handleTouchReleased(_ event: TouchEvent) {
        touchReleasedHandlers.forEach { handler in handler.handle(event) }
    }

    func handleTouchMoved(_ event: TouchEvent) {
        touchMovedHandlers.forEach { handler in handler.handle(event) }
    }

    // MARK: - Multiple tap handling

    func handleTap( _ event: TapEvent ) {
        if isLongTapInProgress {
            prevTouchCount = 0
            return
        }
        if prevTouchTimer != nil {
            prevTouchTimer?.invalidate()
            prevTouchTimer = nil
        }
        prevTouchCount += 1

        for tapCount in tapHandlers.keys {
            if tapCount > prevTouchCount { // wait some more - there is a recognizer for even more taps
                prevTouchTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(onTouchTimer), userInfo: event, repeats: false)
                return
            }
        }

        for (tapCount, handlers) in tapHandlers {
            if tapCount == prevTouchCount { // nothing to wait for - max tap count reached
                handlers.forEach { handler in handler.handle(event) }
                prevTouchCount = 0
            }
        }

    }

    @objc func onTouchTimer(timer: Timer) {
        if isLongTapInProgress {
            prevTouchCount = 0
            return
        }
        for touchCount in tapHandlers.keys.sorted(by: { $0>$1 }) {
            if touchCount <= prevTouchCount, let event = timer.userInfo as? TapEvent {
                // no more taps coming, settle for next best thing
                for _ in 0..<prevTouchCount / touchCount { // might need to call it multiple times
                    tapHandlers[touchCount]?.forEach { handler in handler.handle(event) }
                }
                break
            }
        }
        prevTouchCount = 0
    }

    // MARK: - Helpers

    func handleLongTap( _ event: TapEvent, touchBegan: Bool ) {
        isLongTapInProgress = touchBegan
        if touchBegan {
            return
        }
        longTapHandlers.forEach { handler in handler.handle(event) }
    }

    func handlePan( _ event: PanEvent ) {
        panHandlers.forEach { handler in handler.handle(event) }
    }

    func handleRotate( _ event: RotateEvent ) {
        rotateHandlers.forEach { handler in handler.handle(event) }
    }

    func handlePinch( _ event: PinchEvent ) {
        pinchHandlers.forEach { handler in handler.handle(event) }
    }

    func shouldCheckForPressed() -> Bool {
        return !touchPressedHandlers.isEmpty
    }

    func shouldCheckForMoved() -> Bool {
        return !touchMovedHandlers.isEmpty
    }

    func shouldCheckForReleased() -> Bool {
        return !touchReleasedHandlers.isEmpty
    }

    func shouldCheckForTap() -> Bool {
        return !tapHandlers.isEmpty
    }

    func shouldCheckForLongTap() -> Bool {
        return !longTapHandlers.isEmpty
    }

    func shouldCheckForPan() -> Bool {
        return !panHandlers.isEmpty
    }

    func shouldCheckForRotate() -> Bool {
        return !rotateHandlers.isEmpty
    }

    func shouldCheckForPinch() -> Bool {
        return !pinchHandlers.isEmpty
    }

    public init(place: Transform = Transform.identity,
                opaque: Bool = true,
                opacity: Double = 1,
                clip: Locus? = nil,
                effect: Effect? = nil,
                visible: Bool = true,
                tag: [String] = [],
                attributes: [String: String] = [:]) {
        self.placeVar = AnimatableVariable<Transform>(place)
        self.opaqueVar = Variable<Bool>(opaque)
        self.opacityVar = AnimatableVariable<Double>(opacity)
        self.clipVar = Variable<Locus?>(clip)
        self.effectVar = Variable<Effect?>(effect)
        self.id = NSUUID().uuidString
        self.attributes = attributes

        super.init(
            visible: visible,
            tag: tag
        )
        self.placeVar.node = self
        self.opacityVar.node = self

        Node.map.setObject(self, forKey: self.id as NSString)
    }

    // GENERATED NOT
    internal func bounds() -> Rect? {
        return Rect()
    }

}
