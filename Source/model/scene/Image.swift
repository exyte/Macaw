import Foundation
import RxSwift

public class Image: Node {

	public let srcVar: Variable<String>
	public var src: String {
		get { return srcVar.value }
		set(val) { srcVar.value = val }
	}

	public let xAlignVar: Variable<Align>
	public var xAlign: Align {
		get { return xAlignVar.value }
		set(val) { xAlignVar.value = val }
	}

	public let yAlignVar: Variable<Align>
	public var yAlign: Align {
		get { return yAlignVar.value }
		set(val) { yAlignVar.value = val }
	}

	public let aspectRatioVar: Variable<AspectRatio>
	public var aspectRatio: AspectRatio {
		get { return aspectRatioVar.value }
		set(val) { aspectRatioVar.value = val }
	}

	public let wVar: Variable<Int>
	public var w: Int {
		get { return wVar.value }
		set(val) { wVar.value = val }
	}

	public let hVar: Variable<Int>
	public var h: Int {
		get { return hVar.value }
		set(val) { hVar.value = val }
	}

	public init(src: String, xAlign: Align = .min, yAlign: Align = .min, aspectRatio: AspectRatio = .none, w: Int = 0, h: Int = 0, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
		self.srcVar = Variable<String>(src)
		self.xAlignVar = Variable<Align>(xAlign)
		self.yAlignVar = Variable<Align>(yAlign)
		self.aspectRatioVar = Variable<AspectRatio>(aspectRatio)
		self.wVar = Variable<Int>(w)
		self.hVar = Variable<Int>(h)
		super.init(
			place: place,
			opaque: opaque,
			opacity: opacity,
			clip: clip,
			effect: effect,
			visible: visible,
			tag: tag
		)
	}

}
