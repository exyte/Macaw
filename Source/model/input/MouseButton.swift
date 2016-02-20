import Foundation

public class MouseButton {

	public let pressedProperty: ObservableValue<Bool>
	public var pressed: Bool {
		get { return pressedProperty.get() }
		set(val) { pressedProperty.set(val) }
	}

	public let onPressProperty: ObservableValue<Signal>
	public var onPress: Signal {
		get { return onPressProperty.get() }
		set(val) { onPressProperty.set(val) }
	}

	public let onReleaseProperty: ObservableValue<Signal>
	public var onRelease: Signal {
		get { return onReleaseProperty.get() }
		set(val) { onReleaseProperty.set(val) }
	}

	public let onClickProperty: ObservableValue<Signal>
	public var onClick: Signal {
		get { return onClickProperty.get() }
		set(val) { onClickProperty.set(val) }
	}

	public let onDoubleClickProperty: ObservableValue<Signal>
	public var onDoubleClick: Signal {
		get { return onDoubleClickProperty.get() }
		set(val) { onDoubleClickProperty.set(val) }
	}

	public init(pressed: Bool = false, onPress: Signal, onRelease: Signal, onClick: Signal, onDoubleClick: Signal) {
		self.pressedProperty = ObservableValue<Bool>(value: pressed)	
		self.onPressProperty = ObservableValue<Signal>(value: onPress)	
		self.onReleaseProperty = ObservableValue<Signal>(value: onRelease)	
		self.onClickProperty = ObservableValue<Signal>(value: onClick)	
		self.onDoubleClickProperty = ObservableValue<Signal>(value: onDoubleClick)	
	}

}
