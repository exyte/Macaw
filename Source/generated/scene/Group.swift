import Foundation

public class Group: Node  {

	var contents: [Node] = []

	public init(contents: [Node] = [], pos: Transform, opaque: NSNumber = true, visible: NSNumber = true, clip: Locus, tag: [String] = []) {
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
