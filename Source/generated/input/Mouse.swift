import Foundation

public class Mouse {

	var hover: Bool = false
	var pos: Point
	var onEnter: Signal
	var onExit: Signal
	var onWheel: Signal

	public init(hover: Bool = false, pos: Point, onEnter: Signal, onExit: Signal, onWheel: Signal) {
		self.hover = hover	
		self.pos = pos	
		self.onEnter = onEnter	
		self.onExit = onExit	
		self.onWheel = onWheel	
	}

	// GENERATED NOT
	public func left() -> MouseButton {
		return MouseButton(onPress: Signal(), onRelease: Signal(), onClick: Signal(), onDoubleClick: Signal())
	}
	// GENERATED NOT
	public func middle() -> MouseButton {
        return MouseButton(onPress: Signal(), onRelease: Signal(), onClick: Signal(), onDoubleClick: Signal())
	}
	// GENERATED NOT
	public func right() -> MouseButton {
		return MouseButton(onPress: Signal(), onRelease: Signal(), onClick: Signal(), onDoubleClick: Signal())
	}

}
