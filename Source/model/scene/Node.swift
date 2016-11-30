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

    var tapHandlers = [ChangeHandler<TapEvent>]()
    var panHandlers = [ChangeHandler<PanEvent>]()
    var rotateHandlers = [ChangeHandler<RotateEvent>]()
    var pinchHandlers = [ChangeHandler<PinchEvent>]()
    
    @discardableResult public func onTap(_ f: @escaping (TapEvent) -> ()) -> Disposable  {
        let handler = ChangeHandler<TapEvent>(f)
        tapHandlers.append(handler)
        
        return Disposable({
            guard let index = self.tapHandlers.index(of: handler) else {
                return
            }
            
            self.tapHandlers.remove(at: index)
        })
    }

    @discardableResult public func onPan(_ f: @escaping (PanEvent) -> ()) -> Disposable  {
        let handler = ChangeHandler<PanEvent>(f)
        panHandlers.append(handler)
        
        return Disposable({
            guard let index = self.panHandlers.index(of: handler) else {
                return
            }
            
            self.panHandlers.remove(at: index)
        })
    }
    
    @discardableResult public func onRotate(_ f: @escaping (RotateEvent) -> ()) -> Disposable  {
        let handler = ChangeHandler<RotateEvent>(f)
        rotateHandlers.append(handler)
        
        return Disposable({
            guard let index = self.rotateHandlers.index(of: handler) else {
                return
            }
            
            self.rotateHandlers.remove(at: index)
        })
    }
    
    @discardableResult public func onPinch(_ f: @escaping (PinchEvent) -> ()) -> Disposable  {
        let handler = ChangeHandler<PinchEvent>(f)
        pinchHandlers.append(handler)
        
        return Disposable({
            guard let index = self.pinchHandlers.index(of: handler) else {
                return
            }
            
            self.pinchHandlers.remove(at: index)
        })
    }
    
    func handleTap( _ event: TapEvent ) {
        tapHandlers.forEach { handler in handler.handle(event) }
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


	public init(place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
		self.placeVar = AnimatableVariable<Transform>(place)
		self.opaqueVar = Variable<Bool>(opaque)
		self.opacityVar = AnimatableVariable<Double>(opacity)
		self.clipVar = Variable<Locus?>(clip)
		self.effectVar = Variable<Effect?>(effect)
		super.init(
			visible: visible,
			tag: tag
		)
		self.placeVar.node = self
		self.opacityVar.node = self
	}

	// GENERATED NOT
	internal func bounds() -> Rect? {
		return Rect()
	}

}
