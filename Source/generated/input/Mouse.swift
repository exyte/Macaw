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

	// GENERATED NOT
	func left() -> MouseButton {
        // TODO initial implementation
        return MouseButton(pressed: false, onPress: Signal(), onRelease: Signal(), onClick: Signal(), onDoubleClick: Signal())
	}
	// GENERATED NOT
	func middle() -> MouseButton {
        // TODO initial implementation
        return MouseButton(pressed: false, onPress: Signal(), onRelease: Signal(), onClick: Signal(), onDoubleClick: Signal())
	}
	// GENERATED NOT
	func right() -> MouseButton {
        // TODO initial implementation
        return MouseButton(pressed: false, onPress: Signal(), onRelease: Signal(), onClick: Signal(), onDoubleClick: Signal())
	}

}
