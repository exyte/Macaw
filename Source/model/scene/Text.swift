import Foundation

public class Text: Node  {

	public let textProperty: ObservableValue<String>
	public var text: String {
		get { return textProperty.get() }
		set(val) { textProperty.set(val) }
	}

	public let fontProperty: ObservableValue<Font>
	public var font: Font {
		get { return fontProperty.get() }
		set(val) { fontProperty.set(val) }
	}

	public let fillProperty: ObservableValue<Fill>
	public var fill: Fill {
		get { return fillProperty.get() }
		set(val) { fillProperty.set(val) }
	}

	public let alignProperty: ObservableValue<Align>
	public var align: Align {
		get { return alignProperty.get() }
		set(val) { alignProperty.set(val) }
	}

	public let baselineProperty: ObservableValue<Baseline>
	public var baseline: Baseline {
		get { return baselineProperty.get() }
		set(val) { baselineProperty.set(val) }
	}

	public init(text: String, font: Font, fill: Fill, align: Align = .min, baseline: Baseline = .top, pos: Transform = Transform(), opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.textProperty = ObservableValue<String>(value: text)	
		self.fontProperty = ObservableValue<Font>(value: font)	
		self.fillProperty = ObservableValue<Fill>(value: fill)	
		self.alignProperty = ObservableValue<Align>(value: align)	
		self.baselineProperty = ObservableValue<Baseline>(value: baseline)	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
