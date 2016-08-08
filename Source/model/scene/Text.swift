import Foundation
import RxSwift

public class Text: Node {

	public let textVar: Variable<String>
	public var text: String {
		get { return textVar.value }
		set(val) { textVar.value = val }
	}

	public let fontVar: Variable<Font>
	public var font: Font {
		get { return fontVar.value }
		set(val) { fontVar.value = val }
	}

	public let fillVar: Variable<Fill>
	public var fill: Fill {
		get { return fillVar.value }
		set(val) { fillVar.value = val }
	}

	public let alignVar: Variable<Align>
	public var align: Align {
		get { return alignVar.value }
		set(val) { alignVar.value = val }
	}

	public let baselineVar: Variable<Baseline>
	public var baseline: Baseline {
		get { return baselineVar.value }
		set(val) { baselineVar.value = val }
	}

	public init(text: String, font: Font, fill: Fill, align: Align = .min, baseline: Baseline = .top, pos: Transform = Transform(), opaque: NSObject = true, opacity: Double = 1, clip: Locus? = nil, visible: NSObject = true, tag: [String] = [], bounds: Rect? = nil) {
		self.textVar = Variable<String>(text)
		self.fontVar = Variable<Font>(font)
		self.fillVar = Variable<Fill>(fill)
		self.alignVar = Variable<Align>(align)
		self.baselineVar = Variable<Baseline>(baseline)
		super.init(
			pos: pos,
			opaque: opaque,
			opacity: opacity,
			clip: clip,
			visible: visible,
			tag: tag,
			bounds: bounds
		)
	}

	// GENERATED NOT
	override public func bounds() -> Rect? {
		// TODO: need proper implementation
		return Rect(x: 0.0, y: 0.0, w: 1.0, h: 1.0).applyTransform(self.pos)
	}

}
