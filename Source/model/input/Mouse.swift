import Foundation

public class Mouse {

	public let hoverProperty: ObservableValue<Bool>
	public var hover: Bool {
		get { return hoverProperty.get() }
		set(val) { hoverProperty.set(val) }
	}

	public let posProperty: ObservableValue<Point>
	public var pos: Point {
		get { return posProperty.get() }
		set(val) { posProperty.set(val) }
	}

	public let onEnterProperty: ObservableValue<Signal>
	public var onEnter: Signal {
		get { return onEnterProperty.get() }
		set(val) { onEnterProperty.set(val) }
	}

	public let onExitProperty: ObservableValue<Signal>
	public var onExit: Signal {
		get { return onExitProperty.get() }
		set(val) { onExitProperty.set(val) }
	}

	public let onWheelProperty: ObservableValue<Signal>
	public var onWheel: Signal {
		get { return onWheelProperty.get() }
		set(val) { onWheelProperty.set(val) }
	}

	public init(hover: Bool = false, pos: Point, onEnter: Signal, onExit: Signal, onWheel: Signal) {
		self.hoverProperty = ObservableValue<Bool>(value: hover)	
		self.posProperty = ObservableValue<Point>(value: pos)	
		self.onEnterProperty = ObservableValue<Signal>(value: onEnter)	
		self.onExitProperty = ObservableValue<Signal>(value: onExit)	
		self.onWheelProperty = ObservableValue<Signal>(value: onWheel)	
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
