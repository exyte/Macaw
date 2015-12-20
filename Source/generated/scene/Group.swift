import Foundation

public class Group: Node  {

	var contents: [Node] = []

	public init(contents: [Node] = [], pos: Transform? = nil, opaque: NSObject? = true, visible: NSObject? = true, clip: Locus? = nil, tag: [String] = []) {
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
