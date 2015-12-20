import Foundation

public class Text: Node  {

	var text: String = ""
	var font: Font? = nil
	var fill: Fill? = nil
	var baseline: Baseline? = nil
	var anchor: TextAnchor? = nil

	public init(text: String = "", font: Font? = nil, fill: Fill? = nil, baseline: Baseline? = nil, anchor: TextAnchor? = nil, pos: Transform? = nil, opaque: NSObject? = true, visible: NSObject? = true, clip: Locus? = nil, tag: [String] = []) {
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
