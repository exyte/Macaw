import Foundation

public class Text: Node  {

	var text: String = ""
	var font: Font
	var fill: Fill
	var baseline: Baseline
	var anchor: TextAnchor

	public init(text: String = "", font: Font, fill: Fill, baseline: Baseline, anchor: TextAnchor, pos: Transform, opaque: NSNumber = true, visible: NSNumber = true, clip: Locus, tag: [String] = []) {
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
