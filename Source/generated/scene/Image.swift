import Foundation

public class Image: Node  {

	var src: String
	var xAlign: Align? = nil
	var yAlign: Align? = nil
	var preserveAspectRatio: AspectRatio? = nil
	var w: Int = 0
	var h: Int = 0

	public init(src: String, xAlign: Align? = nil, yAlign: Align? = nil, preserveAspectRatio: AspectRatio? = nil, w: Int = 0, h: Int = 0, pos: Transform? = nil, opaque: NSObject? = true, visible: NSObject? = true, clip: Locus? = nil, tag: [String] = []) {
		self.src = src	
		self.xAlign = xAlign	
		self.yAlign = yAlign	
		self.preserveAspectRatio = preserveAspectRatio	
		self.w = w	
		self.h = h	
		super.init(
			pos: pos,
			opaque: opaque,
			visible: visible,
			clip: clip,
			tag: tag
		)
	}

}
