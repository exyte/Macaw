import Foundation

public class Shape: Node  {

	var form: Locus
	var fill: Fill? = nil
	var stroke: Stroke? = nil

	public init(form: Locus, fill: Fill? = nil, stroke: Stroke? = nil, pos: Transform = Transform(), opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.form = form	
		self.fill = fill	
		self.stroke = stroke	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
