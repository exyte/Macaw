import Foundation
import RxSwift

public class Node: Drawable {

	public let posVar: Variable<Transform>
	public var pos: Transform {
		get { return posVar.value }
		set(val) { posVar.value = val }
	}

	public let opaqueVar: Variable<NSObject>
	public var opaque: NSObject {
		get { return opaqueVar.value }
		set(val) { opaqueVar.value = val }
	}

	public let opacityVar: Variable<Double>
	public var opacity: Double {
		get { return opacityVar.value }
		set(val) { opacityVar.value = val }
	}

	public let clipVar: Variable<Locus?>
	public var clip: Locus? {
		get { return clipVar.value }
		set(val) { clipVar.value = val }
	}

	public init(pos: Transform, opaque: NSObject = true, opacity: Double = 1, clip: Locus? = nil, visible: NSObject = true, tag: [String] = [], bounds: Rect? = nil) {
		self.posVar = Variable<Transform>(pos)
		self.opaqueVar = Variable<NSObject>(opaque)
		self.opacityVar = Variable<Double>(opacity)
		self.clipVar = Variable<Locus?>(clip)
		super.init(
			visible: visible,
			tag: tag,
			bounds: bounds
		)
	}

	// GENERATED NOT
	public func bounds() -> Rect? {
		return Rect()
	}

	// GENERATED NOT
	public override func mouse() -> Mouse {
		return Mouse(pos: Point(), onEnter: Signal(), onExit: Signal(), onWheel: Signal())
	}
}