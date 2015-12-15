import Foundation

class Image: Node  {

	var src: String
	var xAlign: Align
	var yAlign: Align
	var preserveAspectRatio: AspectRatio
	var w: Int
	var h: Int


	init(src: String, xAlign: Align, yAlign: Align, preserveAspectRatio: AspectRatio, w: Int, h: Int) {
		self.src = src	
		self.xAlign = xAlign	
		self.yAlign = yAlign	
		self.preserveAspectRatio = preserveAspectRatio	
		self.w = w	
		self.h = h	
	}

}
