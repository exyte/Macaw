import Foundation

class Node: Drawable  {

	var pos: Transform
	var opaque: Bool = true
	var visible: Bool = true
	var clip: Locus

	init(pos: Transform, opaque: Bool = true, visible: Bool = true, clip: Locus, tag: [String]) {
		self.pos = pos	
		self.opaque = opaque	
		self.visible = visible	
		self.clip = clip	
		super.init(
			tag: tag
		)
	}

	// GENERATED NOT
	func mouse() -> Mouse {
        // TODO initial implementation
		return Mouse(hover: false, pos: Point(), onEnter: Signal(), onExit: Signal(), onWheel: Signal())
	}
	// GENERATED NOT
	func bounds() -> Rect {
        // TODO initial implementation
        return Rect()
	}

}
