import Foundation

public class Image: Node  {

	var src: String
	var xAlign: Align
	var yAlign: Align
	var aspectRatio: AspectRatio
	var w: Int = 0
	var h: Int = 0

	public init(src: String, xAlign: Align, yAlign: Align, aspectRatio: AspectRatio, w: Int = 0, h: Int = 0, pos: Transform = Transform(), opaque: NSObject = true, visible: NSObject = true, clip: Locus? = nil, tag: [String] = []) {
		self.src = src	
		self.xAlign = xAlign	
		self.yAlign = yAlign	
		self.aspectRatio = aspectRatio	
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
