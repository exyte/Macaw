import Foundation

open class Node: Drawable {

    public let placeVar: AnimatableVariable<Transform>
    open var place: Transform {
        get { return placeVar.value }
        set(val) { placeVar.value = val }
    }

    public let opaqueVar: Variable<Bool>
    open var opaque: Bool {
        get { return opaqueVar.value }
        set(val) { opaqueVar.value = val }
    }

    public let opacityVar: AnimatableVariable<Double>
    open var opacity: Double {
        get { return opacityVar.value }
        set(val) { opacityVar.value = val }
    }

    public let clipVar: Variable<Locus?>
    open var clip: Locus? {
        get { return clipVar.value }
        set(val) { clipVar.value = val }
    }

    public let maskVar: Variable<Node?>
    open var mask: Node? {
        get { return maskVar.value }
        set(val) { maskVar.value = val }
    }

    public let effectVar: Variable<Effect?>
    open var effect: Effect? {
        get { return effectVar.value }
        set(val) { effectVar.value = val }
    }

    var animations: [BasicAnimation] = []

    // MARK: - Searching
    public func nodeBy(tag: String) -> Node? {
        return nodeBy(predicate: { $0.tag.contains(tag) })
    }

    public func nodesBy(tag: String) -> [Node] {
        return nodesBy(predicate: { $0.tag.contains(tag) })
    }

    public func nodeBy(predicate: (Node) -> Bool) -> Node? {
        if predicate(self) {
            return self
        }
        return .none
    }

    public func nodesBy(predicate: (Node) -> Bool) -> [Node] {
        return [nodeBy(predicate: predicate)].compactMap { $0 }
    }

    // MARK: - Events
    internal var animationObservers = [AnimationObserver]()

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

        return Disposable { [weak self, unowned handler]  in
            guard let index = self?.touchPressedHandlers.firstIndex(of: handler) else {
                return
            }

            self?.touchPressedHandlers.remove(at: index)
        }
    }

    @discardableResult public func onTouchMoved(_ f: @escaping (TouchEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<TouchEvent>(f)
        touchMovedHandlers.append(handler)

        return Disposable { [weak self, unowned handler] in
            guard let index = self?.touchMovedHandlers.firstIndex(of: handler) else {
                return
            }

            self?.touchMovedHandlers.remove(at: index)
        }
    }

    @discardableResult public func onTouchReleased(_ f: @escaping (TouchEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<TouchEvent>(f)
        touchReleasedHandlers.append(handler)

        return Disposable { [weak self, unowned handler] in
            guard let index = self?.touchReleasedHandlers.firstIndex(of: handler) else {
                return
            }

            self?.touchReleasedHandlers.remove(at: index)
        }
    }

    @discardableResult public func onTap(tapCount: Int = 1, f: @escaping (TapEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<TapEvent>(f)

        var handlers = tapHandlers[tapCount] ?? []
        handlers.append(handler)

        tapHandlers[tapCount] = handlers

        return Disposable { [weak self, unowned handler]  in
            guard let index = self?.tapHandlers[tapCount]?.firstIndex(of: handler) else {
                return
            }

            self?.tapHandlers[tapCount]?.remove(at: index)
        }
    }

    @discardableResult public func onLongTap(_ f: @escaping (TapEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<TapEvent>(f)
        longTapHandlers.append(handler)

        return Disposable { [weak self, unowned handler] in
            guard let index = self?.longTapHandlers.firstIndex(of: handler) else {
                return
            }

            self?.longTapHandlers.remove(at: index)
        }
    }

    @discardableResult public func onPan(_ f: @escaping (PanEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<PanEvent>(f)
        panHandlers.append(handler)

        return Disposable { [weak self, unowned handler] in
            guard let index = self?.panHandlers.firstIndex(of: handler) else {
                return
            }

            self?.panHandlers.remove(at: index)
        }
    }

    @discardableResult public func onRotate(_ f: @escaping (RotateEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<RotateEvent>(f)
        rotateHandlers.append(handler)

        return Disposable { [weak self, unowned handler] in
            guard let index = self?.rotateHandlers.firstIndex(of: handler) else {
                return
            }

            self?.rotateHandlers.remove(at: index)
        }
    }

    @discardableResult public func onPinch(_ f: @escaping (PinchEvent) -> Void) -> Disposable {
        let handler = ChangeHandler<PinchEvent>(f)
        pinchHandlers.append(handler)

        return Disposable { [weak self, unowned handler] in
            guard let index = self?.pinchHandlers.firstIndex(of: handler) else {
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

        for tapCount in tapHandlers.keys where tapCount > prevTouchCount {
            // wait some more - there is a recognizer for even more taps
            prevTouchTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(onTouchTimer), userInfo: event, repeats: false)
            return
        }

        for (tapCount, handlers) in tapHandlers where tapCount == prevTouchCount {
            // nothing to wait for - max tap count reached
            handlers.forEach { handler in handler.handle(event) }
            prevTouchCount = 0
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

    public init(place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, mask: Node? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
        self.placeVar = AnimatableVariable<Transform>(place)
        self.opaqueVar = Variable<Bool>(opaque)
        self.opacityVar = AnimatableVariable<Double>(opacity)
        self.clipVar = Variable<Locus?>(clip)
        self.maskVar = Variable<Node?>(mask)
        self.effectVar = Variable<Effect?>(effect)

        super.init(
            visible: visible,
            tag: tag
        )
        self.placeVar.node = self
        self.opacityVar.node = self
    }

    open var bounds: Rect? {
        return .none
    }

    // MARK: - Hash

    override open var hash: Int {
        var hasher = Hasher()
        hasher.combine(Unmanaged.passUnretained(self).toOpaque())
        return hasher.finalize()
    }

    override open func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? Node else {
            return false
        }
        return Unmanaged.passUnretained(self).toOpaque() == Unmanaged.passUnretained(object).toOpaque()
    }
}
