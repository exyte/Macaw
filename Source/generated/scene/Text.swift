import Foundation

public class Text: Node  {

	var text: String
	var font: Font
	var fill: Fill
	var align: Align = .min
	var baseline: Baseline = .top

	public init(text: String, font: Font, fill: Fill, align: Align = .min, baseline: Baseline = .top, pos: Transform = Transform(), opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.text = text	
		self.font = font	
		self.fill = fill	
		self.align = align	
		self.baseline = baseline	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
