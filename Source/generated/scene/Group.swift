import Foundation

public class Group: Node  {

	var contents: [Node]

	init(contents: [Node], pos: Transform, opaque: Bool, visible: Bool, clip: Locus, tag: [String]) {
		self.contents = contents	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
