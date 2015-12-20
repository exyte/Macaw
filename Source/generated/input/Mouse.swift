import Foundation

public class Mouse {

	var hover: Bool = false
	var pos: Point? = nil
	var onEnter: Signal? = nil
	var onExit: Signal? = nil
	var onWheel: Signal? = nil

	public init(hover: Bool = false, pos: Point? = nil, onEnter: Signal? = nil, onExit: Signal? = nil, onWheel: Signal? = nil) {
		self.hover = hover	
		self.pos = pos	
		self.onEnter = onEnter	
		self.onExit = onExit	
		self.onWheel = onWheel	
	}

	// GENERATED NOT
	public func left() -> MouseButton {
		return MouseButton()
	}
	// GENERATED NOT
	public func middle() -> MouseButton {
		return MouseButton()
	}
	// GENERATED NOT
	public func right() -> MouseButton {
		return MouseButton()
	}

}
