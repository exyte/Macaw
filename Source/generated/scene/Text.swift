import Foundation

public class Text: Node  {

	var text: String = ""
	var font: Font
	var fill: Fill
	var baseline: Baseline
	var anchor: TextAnchor

	init(text: String = "", font: Font, fill: Fill, baseline: Baseline, anchor: TextAnchor, pos: Transform, opaque: Bool, visible: Bool, clip: Locus, tag: [String]) {
		self.text = text	
		self.font = font	
		self.fill = fill	
		self.baseline = baseline	
		self.anchor = anchor	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
