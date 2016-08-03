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

	public let visibleVar: Variable<NSObject>
	public var visible: NSObject {
		get { return visibleVar.value }
		set(val) { visibleVar.value = val }
	}

	public let clipVar: Variable<Locus?>
	public var clip: Locus? {
		get { return clipVar.value }
		set(val) { clipVar.value = val }
	}

	public init(pos: Transform, opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.posVar = Variable<Transform>(pos)
		self.opaqueVar = Variable<NSObject>(opaque)
		self.visibleVar = Variable<NSObject>(visible)
		self.clipVar = Variable<Locus?>(clip)
		super.init(
			tag: tag
		)
	}

	// GENERATED NOT
	public func mouse() -> Mouse {
		return Mouse(pos: Point(), onEnter: Signal(), onExit: Signal(), onWheel: Signal())
	}
	// GENERATED NOT
	public func bounds() -> Rect? {
		return Rect()
	}

}
