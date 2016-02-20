import Foundation

public class Image: Node  {

	public let srcProperty: ObservableValue<String>
	public var src: String {
		get { return srcProperty.get() }
		set(val) { srcProperty.set(val) }
	}

	public let xAlignProperty: ObservableValue<Align>
	public var xAlign: Align {
		get { return xAlignProperty.get() }
		set(val) { xAlignProperty.set(val) }
	}

	public let yAlignProperty: ObservableValue<Align>
	public var yAlign: Align {
		get { return yAlignProperty.get() }
		set(val) { yAlignProperty.set(val) }
	}

	public let aspectRatioProperty: ObservableValue<AspectRatio>
	public var aspectRatio: AspectRatio {
		get { return aspectRatioProperty.get() }
		set(val) { aspectRatioProperty.set(val) }
	}

	public let wProperty: ObservableValue<Int>
	public var w: Int {
		get { return wProperty.get() }
		set(val) { wProperty.set(val) }
	}

	public let hProperty: ObservableValue<Int>
	public var h: Int {
		get { return hProperty.get() }
		set(val) { hProperty.set(val) }
	}

	public init(src: String, xAlign: Align = .min, yAlign: Align = .min, aspectRatio: AspectRatio = .none, w: Int = 0, h: Int = 0, pos: Transform = Transform(), opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.srcProperty = ObservableValue<String>(value: src)	
		self.xAlignProperty = ObservableValue<Align>(value: xAlign)	
		self.yAlignProperty = ObservableValue<Align>(value: yAlign)	
		self.aspectRatioProperty = ObservableValue<AspectRatio>(value: aspectRatio)	
		self.wProperty = ObservableValue<Int>(value: w)	
		self.hProperty = ObservableValue<Int>(value: h)	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
