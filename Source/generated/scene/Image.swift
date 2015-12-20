import Foundation

public class Image: Node  {

	var src: String
	var xAlign: Align
	var yAlign: Align
	var preserveAspectRatio: AspectRatio
	var w: Int
	var h: Int

	init(src: String, xAlign: Align, yAlign: Align, preserveAspectRatio: AspectRatio, w: Int, h: Int, pos: Transform, opaque: NSNumber = true, visible: NSNumber = true, clip: Locus, tag: [String] = []) {
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
