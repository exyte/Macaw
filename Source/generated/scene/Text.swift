import Foundation

class Text: Node  {

	var text: String = ""
	var font: Font
	var fill: Fill
	var baseline: Baseline
	var anchor: TextAnchor


	init(text: String = "", font: Font, fill: Fill, baseline: Baseline, anchor: TextAnchor) {
		self.text = text	
		self.font = font	
		self.fill = fill	
		self.baseline = baseline	
		self.anchor = anchor	
	}

}
