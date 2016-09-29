import Foundation
import RxSwift

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

    public let onTap = PublishSubject<TapEvent>()
    public let onPan = PublishSubject<PanEvent>()
    public let onRotate = PublishSubject<RotateEvent>()
    public let onPinch = PublishSubject<PinchEvent>()

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
