import Foundation
import RxSwift

public class Text: Node {

	public let textVar: Variable<String>
	public var text: String {
		get { return textVar.value }
		set(val) { textVar.value = val }
	}

	public let fontVar: Variable<Font?>
	public var font: Font? {
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

	public init(text: String, font: Font? = nil, fill: Fill = Color.black, align: Align = .min, baseline: Baseline = .top, place: Transform = Transform.identity, opaque: Bool = true, opacity: Double = 1, clip: Locus? = nil, effect: Effect? = nil, visible: Bool = true, tag: [String] = []) {
		self.textVar = Variable<String>(text)
		self.fontVar = Variable<Font?>(font)
		self.fillVar = Variable<Fill>(fill)
		self.alignVar = Variable<Align>(align)
		self.baselineVar = Variable<Baseline>(baseline)
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

	// GENERATED NOT
	override internal func bounds() -> Rect {
        let font: UIFont
        if let f = self.font {
            if let customFont = UIFont(name: f.name, size: CGFloat(f.size)) {
                font = customFont
            } else {
                font = UIFont.systemFontOfSize(CGFloat(f.size))
            }
        } else {
            font = UIFont.systemFontOfSize(UIFont.systemFontSize())
        }
        var stringAttributes: [String: AnyObject] = [:]
        stringAttributes[NSFontAttributeName] = font
        let size = (text as NSString).sizeWithAttributes(stringAttributes)
        return Rect(x: place.dx, y: place.dy, w: Double(size.width), h: Double(size.height))
	}

}
