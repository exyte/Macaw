import Foundation

class Mouse {

	var hover: Bool
	var pos: Point
	var onEnter: Signal
	var onExit: Signal
	var onWheel: Signal


	init(hover: Bool, pos: Point, onEnter: Signal, onExit: Signal, onWheel: Signal) {
		self.hover = hover	
		self.pos = pos	
		self.onEnter = onEnter	
		self.onExit = onExit	
		self.onWheel = onWheel	
	}

	// GENERATED
	func left() -> MouseButton {
		
	}

	// GENERATED
	func middle() -> MouseButton {
		
	}

	// GENERATED
	func right() -> MouseButton {
		
	}

}
