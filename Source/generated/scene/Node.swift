import Foundation

class Node: Drawable  {

	var pos: Transform
	var opaque: Bool = true
	var visible: Bool = true
	var clip: Locus


	init(pos: Transform, opaque: Bool = true, visible: Bool = true, clip: Locus) {
		self.pos = pos	
		self.opaque = opaque	
		self.visible = visible	
		self.clip = clip	
	}

	// GENERATED
	func mouse() -> Mouse {
		
	}

	// GENERATED
	func bounds() -> Rect {
		
	}

}
